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
    ingest.update(status: Ingest.statuses[:completed])
  rescue RuntimeError
    ingest.update(status: Ingest.statuses[:errored])
  end

  def perform(ingest)
    processed = 0
    metadata = JSON.parse(ingest.manifest.download)
    docs = metadata.dig('response', 'docs')
    docs.each do |doc|
      process_record(doc)
      processed += 1
      # use update_column for fast updates - bypass validations & callbacks becuse we're only incremeting a counter
      ingest.update_column(:processed, processed) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def process_record(doc)
    blueprint_name = doc['has_model_ssim']&.first
    blueprint = Blueprint.find_by(name: blueprint_name)
    blueprint ||= Blueprint.find_by(name: 'Default') # TODO: remove when more blueprint functionality exists
    d2 = {}
    doc.each do |key, value|
      new_key = blueprint.fields.find { |f| f.solr_field_name == key }&.display_label || key
      d2[new_key] = value
    end
    Item.create(blueprint: blueprint, description: d2)
  end
end
