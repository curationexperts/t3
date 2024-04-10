# Container for Items
# Shares most Item behaviors
class Collection < Item
  # To inherit without using STI, we need to set the table name explicitly
  self.table_name = 'collections'

  # Use items partials instead of looking for separate collection partials
  def to_partial_path
    # self.class.superclass.new.to_partial_path
    'admin/items/item'
  end
end
