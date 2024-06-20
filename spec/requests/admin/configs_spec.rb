require 'rails_helper'

RSpec.describe '/admin/configs' do
  # This should return the minimal set of attributes required to create a valid
  # Config. As you add validations to Config, be sure to
  # adjust the attributes here as well.
  let(:super_admin)  { FactoryBot.create(:super_admin) }
  let(:regular_user) { FactoryBot.create(:user) }

  before { login_as super_admin }

  describe 'GET /index' do
    it 'is not implemented' do
      expect do
        Admin::ConfigsController.new.index
      end.to raise_exception(NoMethodError)
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      get config_url
      expect(response).to be_successful
    end

    it 'appears under the status navigation menu' do
      get config_url
      page = Capybara.string(response.body)
      expect(page).to have_link(href: status_path, class: 'nav-link active')
    end

    it 'can render as json' do
      get config_url(format: :json)
      json = response.parsed_body
      expect(json).to include(
        'url' => 'http://www.example.com/admin/config.json',
        'context' => a_hash_including('description' => 'T3 Configuration export')
      )
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      get edit_config_url
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'is not implemented' do
      expect do
        Admin::ConfigsController.new.new
      end.to raise_exception(NoMethodError)
    end
  end

  describe 'POST /create' do
    it 'is not implemented' do
      expect do
        Admin::ConfigsController.new.create
      end.to raise_exception(NoMethodError)
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:valid_config) do
        fixture_file_upload('config/minimal_valid_config.json')
      end

      it 'updates the requested config' do
        patch config_url, params: { config_file: valid_config }
        json = Config.current.settings.as_json
        expect(json).to include('fields' => a_collection_including(a_hash_including('name' => 'New Field')))
      end

      it 'redirects to the config' do
        patch config_url, params: { config_file: valid_config }
        expect(response).to redirect_to(config_url)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_config) do
        fixture_file_upload('config/minimal_invalid_config.json')
      end

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        patch config_url, params: { config_file: invalid_config }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'is not implemented' do
      expect do
        Admin::ConfigsController.new.destroy
      end.to raise_exception(NoMethodError)
    end
  end

  describe 'resctricts access' do
    example 'for guest users' do
      logout
      get edit_config_url
      expect(response).to be_not_found
    end

    example 'for non-admin users' do
      login_as regular_user
      get edit_config_url
      expect(response).to be_unauthorized
    end
  end
end
