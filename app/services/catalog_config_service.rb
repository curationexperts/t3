# Encapsulates logic that builds Blacklight Catalog configuration from
# current Field configurations
class CatalogConfigService
  def self.update_catalog_controller
    new.update_catalog_controller
  end

  def update_catalog_controller # rubocop:disable Metrics/AbcSize
    CatalogController.configure_blacklight do |config|
      config.connection_config[:url] = SolrService.current.url
      config.search_fields = blacklight_fields_from_config.search_fields
      config.facet_fields = blacklight_fields_from_config.facet_fields
      config.index_fields = blacklight_fields_from_config.index_fields
      config.show_fields = blacklight_fields_from_config.show_fields
      config.index.title_field = title_field
    end
  end

  private

  def blacklight_fields_from_config
    config = Blacklight::Configuration.new
    add_all_field_search(config)
    add_title_search(config)

    # NOTE: skip the first field because it's always used as the main title field for Blacklight
    Field.active_in_sequence[1..]&.each do |field|
      update_field(config, field)
    end
    config.add_show_field 'files_ssm', label: 'Files', helper_method: :file_links
    config
  end

  def add_all_field_search(config)
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = Field.active_in_sequence.map(&:solr_field_name).join(' ')
      field.solr_parameters = {
        qf: "#{all_names} id",
        pf: title_field
      }
    end
  end

  def add_title_search(config)
    return unless title_field

    config.add_search_field(title_field, label: title_label) do |field|
      field.solr_parameters = { qf: title_field }
    end
  end

  def update_field(config, field)
    configure_search(config, field)
    configure_facet(config, field)
    configure_index(config, field)
    configure_show(config, field)
  end

  def configure_search(config, field)
    return unless field.searchable

    config.add_search_field(field.solr_field_name,
                            label: field.name,
                            solr_parameters: { df: field.solr_field_name })
  end

  def configure_facet(config, field)
    config.add_facet_field(field.solr_facet_field, label: field.name, limit: 10) if field.facetable
  end

  def configure_index(config, field)
    config.add_index_field(field.solr_field_name, label: field.name) if field.list_view
  end

  def configure_show(config, field)
    config.add_show_field(field.solr_field_name, label: field.name) if field.item_view
  end

  def title_field
    @title_field ||= Field.active_in_sequence.first&.solr_field_name
  end

  def title_label
    Field.active_in_sequence.first&.name
  end
end
