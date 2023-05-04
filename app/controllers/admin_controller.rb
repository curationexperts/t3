# Administrator dashboard controller
class AdminController < ApplicationController
  def show; end

  def update
    field_config = params.require(:repository_configuration).permit(fields_attributes: %i[name label index show search facet])
    RepositoryConfiguration.current.assign_attributes(field_config)
    update_catalog_config
  end

  def self.available_solr_fields
    repo = CatalogController.blacklight_config.repository
    r = repo.send_and_receive('admin/luke', {})
    r['fields']
  end

  def self.total_docs
    repo = CatalogController.blacklight_config.repository
    r = repo.send_and_receive('/api/cores/blacklight-core', {})
    r.dig('status', 'blacklight-core', 'index', 'numDocs')
    response = repo.send_and_receive('select', { 'q' => '*:*', 'rows' => '0' })
    response.dig('response', 'numFound')
  end

  def update_catalog_config
    CatalogController.configure_blacklight do |config|
      config.index_fields = {}
      config.show_fields = {}
      RepositoryConfiguration.current.fields.each do |f|
        config.add_index_field f.name, label: f.label if f.index
        config.add_show_field  f.name, label: f.label if f.show
      end
    end
  end
end
