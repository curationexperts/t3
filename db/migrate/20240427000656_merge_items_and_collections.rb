class MergeItemsAndCollections < ActiveRecord::Migration[7.0]
  def up
    create_table 'resources', force: false do |t|
      t.string 'type', null: false
      t.references :blueprint, null: false, foreign_key: true
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.jsonb 'metadata'
    end

    # Copy Items to Resources retaining IDs - so we keep ActiveStorage associations
    ActiveRecord::Base.connection
                      .execute('INSERT INTO resources (id, type, blueprint_id, created_at, updated_at, metadata)' \
                               "SELECT id, 'Item' as type, blueprint_id, created_at, updated_at, metadata FROM items;")
    # Copy Collections to Resources - assigning new IDs
    ActiveRecord::Base.connection
                      .execute('INSERT INTO resources (type, blueprint_id, created_at, updated_at, metadata)' \
                               "SELECT 'Collection' as type, blueprint_id, created_at, updated_at, metadata FROM collections;") # rubocop:disable Layout/LineLength

    drop_table 'collections'
    drop_table 'items'
  end

  def down
    create_table 'items', force: false do |t|
      t.references :blueprint, null: false, foreign_key: true
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.jsonb 'metadata'
    end

    create_table 'collections', force: false do |t|
      t.references :blueprint, null: false, foreign_key: true
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.jsonb 'metadata'
    end

    # Copy (Item)Resources to Items retaining IDs - so we keep ActiveStorage associations
    ActiveRecord::Base.connection
                      .execute('INSERT INTO items (id, blueprint_id, created_at, updated_at, metadata) ' \
                               'SELECT id, blueprint_id, created_at, updated_at, metadata FROM resources ' \
                               "WHERE type = 'Item';")
    # Copy ()Collection)Resources to Collections - assigning new IDs
    ActiveRecord::Base.connection
                      .execute('INSERT INTO collections (blueprint_id, created_at, updated_at, metadata) ' \
                               'SELECT blueprint_id, created_at, updated_at, metadata FROM resources ' \
                               "WHERE type = 'Collection';")

    drop_table 'resources'
  end
end
