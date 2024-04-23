# Local helpers to extend document display capabilities for
# Blacklight Catalog Controller based views
# e.g. Solr document show and related partials
module DocumentHelper
  def file_links(options)
    files = options[:value]
    tag.div(id: 'file_links', escape: false) do
      links = files.map do |signed_id|
        file = ActiveStorage::Blob.find_signed!(signed_id)
        link_to file.filename, url_for(file)
      end
      to_sentence(links)
    end
  end
end
