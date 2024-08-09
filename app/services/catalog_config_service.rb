# Encapsulates logic that builds Blacklight Catalog configuration from
# current Field configurations
class CatalogConfigService
  def self.update_catalog_controller
    new.update_catalog_controller
  end

  def update_catalog_controller # rubocop:disable Metrics/AbcSize
    CatalogController.configure_blacklight do |config|
      config.connection_config[:url] = solr_connection_from_config
      config.facet_fields = blacklight_fields_from_config.facet_fields
      config.index_fields = blacklight_fields_from_config.index_fields
      config.show_fields = blacklight_fields_from_config.show_fields
      config.index.title_field = title_field_from_config
    end
  end

  private

  def blacklight_fields_from_config
    config = Blacklight::Configuration.new
    # NOTE: skip the first field because it's always used as the main title field for Blacklight
    Field.active_in_sequence[1..]&.each do |field|
      update_field(config, field)
    end
    config.add_show_field 'files_ssm', label: 'Files', helper_method: :file_links
    config
  end

  def update_field(config, field)
    config.add_facet_field(field.solr_facet_field, label: field.name, limit: 10) if field.facetable
    config.add_index_field(field.solr_field_name, label: field.name) if field.list_view
    config.add_show_field(field.solr_field_name, label: field.name) if field.item_view
  end

  def title_field_from_config
    Field.active_in_sequence.first&.solr_field_name
  end

  def solr_connection_from_config
    "#{SolrService.current.solr_host}/solr/#{SolrService.current.solr_core}"
  end
end
