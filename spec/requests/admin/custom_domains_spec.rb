require 'rails_helper'

RSpec.describe '/admin/custom_domains' do
  # This should return the minimal set of attributes required to create a valid
  # CustomDomain. As you add validations to CustomDomain, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { host: 'my-host.example.com' } }
  let(:invalid_attributes) { { host: 'not_a_valid_domain' } }

  let(:super_admin)  { FactoryBot.create(:super_admin) }
  let(:regular_user) { FactoryBot.create(:user) }

  before do
    # Stub DNS requests to isolate external services
    allow(Resolv).to receive(:getaddress).and_return('10.10.0.1')
    login_as super_admin
    allow(Certbot::V2::Client).to receive(:new).and_return(Certbot::V2::TestClient.new)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      CustomDomain.create! valid_attributes
      get custom_domains_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'does not respond' do
      custom_domain = CustomDomain.create! valid_attributes
      expect { get custom_domain_url(custom_domain) }.to raise_exception(ActionController::RoutingError)
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_custom_domain_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'does not respond' do
      custom_domain = CustomDomain.create! valid_attributes
      expect { get edit_custom_domain_url(custom_domain) }.to raise_exception(NoMethodError)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new CustomDomain' do
        expect do
          post custom_domains_url, params: { custom_domain: valid_attributes }
        end.to change(CustomDomain, :count).by(1)
      end

      it 'redirects to the created custom_domain' do
        post custom_domains_url, params: { custom_domain: valid_attributes }
        expect(response).to redirect_to(custom_domains_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new CustomDomain' do
        expect do
          post custom_domains_url, params: { custom_domain: invalid_attributes }
        end.not_to change(CustomDomain, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post custom_domains_url, params: { custom_domain: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { host: 'new-domain.example.com' } }

      it 'updates the requested custom_domain' do
        custom_domain = CustomDomain.create! valid_attributes
        expect do
          patch custom_domain_url(custom_domain), params: { custom_domain: new_attributes }
        end.to raise_exception(ActionController::RoutingError)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested custom_domain' do
      custom_domain = CustomDomain.create! valid_attributes
      expect do
        delete custom_domain_url(custom_domain)
      end.to change(CustomDomain, :count).by(-1)
    end

    it 'redirects to the custom_domains list' do
      custom_domain = CustomDomain.create! valid_attributes
      delete custom_domain_url(custom_domain)
      expect(response).to redirect_to(custom_domains_url)
    end
  end

  describe 'resctricts access' do
    example 'for guest users' do
      logout
      get custom_domains_url
      expect(response).to be_not_found
    end

    example 'for non-admin users' do
      login_as regular_user
      get custom_domains_url
      expect(response).to be_unauthorized
    end
  end
end
