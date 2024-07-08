json.extract! field, :sequence, :id, :name, :data_type, :vocabulary_id, :source_field, :active, :required,
              :multiple, :list_view, :item_view, :searchable, :facetable, :created_at, :updated_at
json.url field_url(field, format: :json)
