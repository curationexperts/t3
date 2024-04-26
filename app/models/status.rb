# Placeholder singleton for Dashboard Status code
class Status
  extend ActiveModel::Naming

  model_name.plural = 'status'
  model_name.route_key = 'status'
end
