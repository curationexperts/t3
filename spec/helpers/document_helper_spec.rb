require 'rails_helper'

RSpec.describe DocumentHelper do
  let(:options) { { value: [this.signed_id, the_other.signed_id] } }
  let(:this) { ActiveStorage::Blob.create_before_direct_upload!(filename: 'image.jpg', byte_size: 0, checksum: 0) }
  let(:the_other) do
    ActiveStorage::Blob.create_before_direct_upload!(filename: 'document.pdf', byte_size: 0, checksum: 0)
  end

  before do
    ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
  end

  describe '#file_links' do
    let(:file_links) { helper.file_links(options) }

    it 'wraps the links in a div with a unique id' do
      expect(file_links).to have_selector('div#file_links')
    end

    it 'renders a link for each attached file', :aggregate_failures do
      expect(file_links).to have_link('image.jpg', href: url_for(this))
      expect(file_links).to have_link('document.pdf', href: url_for(the_other))
    end

    it 'raises an exception on invalid signed_ids' do
      expect do
        helper.file_links({ value: ['invalid_signature'] })
      end.to raise_exception ActiveSupport::MessageVerifier::InvalidSignature
    end
  end
end
