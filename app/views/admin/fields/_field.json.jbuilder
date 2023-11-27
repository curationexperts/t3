json.extract! field, :id, :name, :data_type, :source_field, :active, :required, :multiple, :list_view, :item_view,
              :searchable, :facetable, :created_at, :updated_at
json.url field_url(field, format: :json)
