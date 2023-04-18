require 'csv'

# Import related Thor tasks
class Import < Thor
  def self.exit_on_failure?
    true
  end

  desc 'noodle FILE', 'test the infrastructure'
  def noodle(file)
    puts "Sound like you'd like to import #{file}"
  end

  desc 'csv FILE', 'Import works from a CSV'
  def csv(file)
    records = CSV.read(file, headers: true)
    blueprint = Blueprint.last
    fields = blueprint.fields
    delimiter = '|~|'

    if records.headers.count < 2 || records.count < 1
      raise Thor::MalformattedArgumentError,
            'The CSV is can not be parsed successfully'
    end
    raise Thor::InvocationError, 'No Blueprints are defined' if Blueprint.count < 1

    records.each do |record|
      puts "Importing [#{record['identifier']}] #{record['title']}"
      description = {}
      fields.each do |field|
        description[field.name] = field.multiple ? [] : ''
        cell = record[field.name]
        cell = cell&.split(delimiter) if field.multiple
        description[field.name] = cell
      end
      work = Work.create(description: description, blueprint: blueprint)
    end
  end

  desc 'index', '(Re)Generate the Solr index'
  def index
    solr_connection = CatalogController.blacklight_config.repository.connection
    total_works = Work.count
    i = 1
    Work.all.each do |work|
      next unless work.description['identifier']

      printf("\r%d of %d", i, total_works)
      i += 1
      document = work.to_solr
      solr_connection.update params: {}, data: { add: { doc: document } }.to_json,
                             headers: { 'Content-Type' => 'application/json' }
    end
    solr_connection.update params: {}, data: { commit: {} }.to_json, headers: { 'Content-Type' => 'application/json' }
  end
end
