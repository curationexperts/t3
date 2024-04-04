# Container for Items
# Shares most Item behaviors
class Collection < Item
  # To inherit without using STI, we need to set the table name explicitly
  self.table_name = 'collections'
end
