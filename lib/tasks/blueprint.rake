namespace :blueprint do
  desc 'Dump existing blueprints'
  task dump: :environment do
    band = ' ==================================================================================================='
    Blueprint.all.each do |blueprint|
      printf("\n[%4d] %.50s \n", blueprint.id, blueprint.name + band)
      blueprint.fields.sort_by(&:order).each do |field|
        printf("%8d %-25s: %-8s %-6s  %3d\n", field.id, field.name, field.data_type, (field.multiple ? 'multi' : ''),
               field.order)
      end
    end
  end

  desc 'Create a default group of blueprints'
  task seed: :environment do
    blueprint = Blueprint.create(name: 'tenejo_work')
    blueprint.fields.create(name: 'identifier',             data_type: 'string', multiple: false)
    blueprint.fields.create(name: 'object_type',            data_type: 'string', multiple: false)
    blueprint.fields.create(name: 'visibility',             data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'parent',                 data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'title',                  data_type: 'text',   multiple: false)
    blueprint.fields.create(name: 'files',                  data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'abstract',               data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'access_right',           data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'alternative_title',      data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'based_near',             data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'bibliographic_citation', data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'contributor',            data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'creator',                data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'date_accepted',          data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'date_copyrighted',       data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'date_created',           data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'date_issued',            data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'date_normalized',        data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'description',            data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'extent',                 data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'genre',                  data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'import_url',             data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'keyword',                data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'language',               data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'license',                data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'other_identifiers',      data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'publisher',              data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'related_url',            data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'relative_path',          data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'resource_format',        data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'resource_type',          data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'rights_notes',           data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'rights_statement',       data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'source',                 data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'subject',                data_type: 'text',   multiple: true)
    blueprint.fields.create(name: 'on_behalf_of',           data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'owner',                  data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'proxy_depositor',        data_type: 'string', multiple: true)
    blueprint.fields.create(name: 'error',                  data_type: 'string', multiple: true)
  end
end

# NOTES:
# Add a field control for faceting
# Add an 'ignore' flag for import crosswalks
# visibility: download, read, write, inherit
