require 'rails_helper'

RSpec.describe '/adim/roles' do
  # This should return the minimal set of attributes required to create a valid
  # Role. As you add validations to Role, be sure to adjust the attributes here as well.
  let(:valid_attributes)   { { name: 'a_role', description: 'What the role does' } }
  let(:invalid_attributes) { { name: nil,      description: 'What the role does' } }
  let(:super_admin)  { FactoryBot.create(:super_admin) }
  let(:regular_user) { FactoryBot.create(:user) }

  before { login_as super_admin }

  describe 'GET /index' do
    it 'renders a successful response' do
      Role.create! valid_attributes
      get roles_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      role = Role.create! valid_attributes
      get role_url(role)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_role_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      role = Role.create! valid_attributes
      get edit_role_url(role)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Role' do
        expect do
          post roles_url, params: { role: valid_attributes }
        end.to change(Role, :count).by(1)
      end

      it 'redirects to the created role' do
        post roles_url, params: { role: valid_attributes }
        expect(response).to redirect_to(role_url(Role.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Role' do
        expect do
          post roles_url, params: { role: invalid_attributes }
        end.not_to change(Role, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post roles_url, params: { role: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { description: 'An updated description' } }

      it 'updates the requested role' do
        role = Role.create! valid_attributes
        patch role_url(role), params: { role: new_attributes }
        role.reload
        expect(role.description).to eq 'An updated description'
      end

      it 'redirects to the role' do
        role = Role.create! valid_attributes
        patch role_url(role), params: { role: new_attributes }
        role.reload
        expect(response).to redirect_to(role_url(role))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        role = Role.create! valid_attributes
        patch role_url(role), params: { role: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested role' do
      role = Role.create! valid_attributes
      expect do
        delete role_url(role)
      end.to change(Role, :count).by(-1)
    end

    it 'redirects to the roles list' do
      role = Role.create! valid_attributes
      delete role_url(role)
      expect(response).to redirect_to(roles_url)
    end

    describe 'system roles' do
      it 'cannot be deleted' do
        role = Role.system_roles.first
        delete role_url(role)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'resctricts access' do
    example 'for guest users' do
      logout
      get roles_url
      expect(response).to be_not_found
    end

    example 'for non-admin users' do
      login_as regular_user
      get roles_url
      expect(response).to be_unauthorized
    end
  end
end
