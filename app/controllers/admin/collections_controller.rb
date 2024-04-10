module Admin
  # Controller for UI to manage Collections stored in the repository
  class CollectionsController < ItemsController
    load_resource class: Collection, instance_name: :item, param_method: :item_params
  end
end
