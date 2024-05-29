# Iterate over items in an Ingest manifest and
# create associated repository objects
class ImportJob < ApplicationJob
  require 'open-uri'

  queue_as :default

  after_enqueue { arguments.first.queued! }

  before_perform { raise ArgumentError unless arguments.first.is_a?(Ingest) }

  def perform(ingest)
    @report = Report.new(ingest)
    records(ingest).each.with_index(1) do |doc, index|
      logger.measure_info('Created item from metadata', payload: { manifest_record: index }, metric: 'item/import') do
        @report << process_record(doc, index)
      end
    end
  rescue StandardError => e
    @report.record_error(e)
  ensure
    @report.save
  end

  # return the list of metadata records from the attached manifest
  def records(ingest)
    metadata = JSON.parse(ingest.manifest.download)
    metadata.dig('response', 'docs')
  end

  # Transform the metadata into an Item saved to the database
  def process_record(doc, index = nil)
    blueprint = find_blueprint(doc)
    metadata = build_description(blueprint, doc)
    save_record(blueprint, metadata)
  rescue StandardError => e
    @report.record_error(e, doc, index)
  end

  private

  # Return the blueprint object matching the name from the input document
  def find_blueprint(doc)
    blueprint_name = doc['has_model_ssim']&.first
    Blueprint.find_by(name: blueprint_name) || Blueprint.find_by(name: 'Default')
  end

  # Return a hash with incoming document keys mapped to their blueprint targets
  def build_description(blueprint, doc)
    doc.transform_keys(blueprint.key_map).merge({ ingest_snippet: doc.to_json[0..99] })
  end

  # Save a new Item, rescuing & capturing exceptions
  def save_record(blueprint, metadata)
    attachables = fetch_files(metadata)
    item = Item.create!(blueprint: blueprint, metadata: metadata, files: attachables)
    { id: item.id, status: 'created', timestamp: Time.current.iso8601(3) }
  end

  def fetch_files(metadata)
    files = metadata['files']
    return unless files.respond_to?(:map)

    files.map do |reference|
      reference_io = read_from(reference['url'])
      blob = ActiveStorage::Blob.create_and_upload!(io: reference_io, filename: reference['name'],
                                                    content_type: 'application/octet-stream', identify: false)
      reference_io.close
      blob
    end
  end

  def read_from(url)
    case url
    when /http/
      # Use URI.parse to prevent code injection - https://docs.rubocop.org/rubocop/cops_security.html#securityopen
      URI.parse(url).open
    else
      File.open(url)
    end
  end

  # Utility class to encapsulate the details of status reporting from
  # the rest of the import process
  class Report
    def initialize(ingest)
      @ingest = ingest
      @start_time = Time.current.iso8601(3)
      @statuses = []
      @errors = []
      @ingest.processing!
    end

    def <<(json)
      @statuses << json
      broadcast_status
    end

    def processed
      @statuses.count
    end

    def errored
      @errors.count
    end

    def final_status
      errored.zero? ? 'completed' : 'errored'
    end

    def save
      @ingest.update(status: final_status, processed: processed, error_count: errored)
      attach_report
      broadcast_status
    end

    # Assemble artifacts into a pretty JSON file and attach to the ingest record
    def attach_report
      report = JSON.pretty_generate({ context: context, items: @statuses, errors: @errors })
      @ingest.report.attach(
        io: StringIO.open(report),
        filename: "import#{@ingest.id}.json",
        content_type: 'application/json'
      )
      # Update browser clients watching the import (using Turbo Streams)
      @ingest.broadcast_replace_to 'ingests', partial: 'admin/ingests/report', target: "report_ingest_#{@ingest.id}"
    end

    def context
      {
        ingest_id: @ingest.id,
        submitted_by: @ingest.user.display_name,
        submitted: @ingest.created_at,
        started: @start_time,
        finished: Time.current.iso8601(3),
        status: @ingest.status,
        processed: @ingest.processed,
        errored: @ingest.error_count
      }
    end

    def broadcast_status
      # Update the processed item count in the database and broadcast to any watching clients
      @ingest.update_column(:processed, processed) # rubocop:disable Rails/SkipsModelValidations
      # Update browser clients watching the import (using Turbo Streams)
      @ingest.broadcast_replace_to 'ingests', partial: 'admin/ingests/status', target: "status_ingest_#{@ingest.id}"
    end

    def record_error(err, doc = nil, index = nil)
      ImportJob.logger.error err
      @errors << { id: "manifest_record_#{index || 'none'}", error_class: err.class,
                   message: err.message, document: (doc || 'none') }
      # broadcast_status
      { id: "manifest_record_#{index}", status: 'errored', timestamp: Time.current.iso8601(3) }
    end
  end
end
