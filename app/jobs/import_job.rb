# Iterate over items in an Ingest manifest and
# create associated repository objects
class ImportJob < ApplicationJob
  queue_as :default

  after_enqueue do |job|
    ingest = job.arguments.first
    ingest.update(status: Ingest.statuses[:queued])
  end

  around_perform do |job, block|
    raise ArgumentError unless job.arguments.first.is_a?(Ingest)

    ingest = job.arguments.first
    ingest.update(status: Ingest.statuses[:processing])
    block.call
    ingest.update(status: Ingest.statuses[:completed]) if ingest.error_count.zero?
    ingest.update(status: Ingest.statuses[:errored]) if ingest.error_count.positive?
  rescue RuntimeError => e
    ingest.update(status: Ingest.statuses[:errored])
    logger.error e
  end

  def perform(ingest)
    report = Report.new(ingest)
    metadata = JSON.parse(ingest.manifest.download)
    docs = metadata.dig('response', 'docs')
    docs.each.with_index do |doc, index|
      logger.measure_info('Created item from metadata record', payload: { manifest_record: index + 1 },
                                                               metric: 'item/import') do
        report << process_record(doc)
        # use update_column for fast updates - bypass validations & callbacks becuse we're only incremeting a counter
        ingest.update_column(:processed, report.processed) # rubocop:disable Rails/SkipsModelValidations
      end
    end
    report.save
  end

  def process_record(doc)
    blueprint = find_blueprint(doc)
    description = build_description(blueprint, doc)
    save_record(blueprint, description)
  end

  # Return the blueprint object matching the name from the input document
  def find_blueprint(doc)
    blueprint_name = doc['has_model_ssim']&.first
    Blueprint.find_by(name: blueprint_name) || Blueprint.find_by(name: 'Default')
  end

  # Return a hash with incoming document keys mapped to their blueprint targets
  def build_description(blueprint, doc)
    doc.transform_keys(blueprint.key_map).merge({ ingest_key: doc.to_json[0..99] })
  end

  # Save a new Item, rescuing & capturing exceptions
  def save_record(blueprint, description)
    item = Item.create(blueprint: blueprint, description: description)
    { id: item.id, status: 'created', timestamp: Time.current.iso8601(3) }
  rescue RuntimeError => e
    logger.error { "#{e}: #{e.message}" }
    { id: nil, status: 'error', timestamp: Time.current.iso8601(3), error_class: e.class, message: e.message,
      ref: description[:ingest_key] }
  end

  # Utility class to encapsulate the details of status reporting from
  # the rest of the import process
  class Report
    def initialize(ingest)
      @ingest = ingest
      @context = {
        ingest_id: ingest.id,
        submitted_by: ingest.user.display_name,
        submitted: ingest.created_at,
        started: Time.current.iso8601(3)
      }
      @statuses = []
    end

    def <<(json)
      @statuses << json
    end

    def processed
      @statuses.count
    end

    def errored
      @statuses.select { |item| item[:status] == 'error' }.count
    end

    def save
      @ingest.update(error_count: errored)
      @context.merge!({
                        finished: Time.current.iso8601(3),
                        status: errored.zero? ? 'completed' : 'errored',
                        processed: processed,
                        errored: @ingest.error_count
                      })
      report = { context: @context, items: @statuses }
      @ingest.report.attach(
        io: StringIO.open(report.to_json),
        filename: "import#{@ingest.id}.json",
        content_type: 'application/json'
      )
    end
  end
end
