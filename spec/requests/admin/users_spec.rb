require 'rails_helper'

RSpec.describe '/admin/users' do
  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to adjust the attributes here as well.
  let(:valid_attributes) { { email: Faker::Internet.email, password: Faker::Internet.password } }
  let(:invalid_attributes) { { email: nil, password: nil } }
  let(:super_admin)  { FactoryBot.create(:super_admin) }
  let(:regular_user) { FactoryBot.create(:user) }

  before { login_as super_admin }

  describe 'GET /index' do
    it 'renders a successful response' do
      FactoryBot.create(:user)
      get users_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      user = User.create! valid_attributes
      get user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_user_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      user = User.create! valid_attributes
      get edit_user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new User' do
        expect do
          post users_url, params: { user: valid_attributes }
        end.to change(User, :count).by(1)
      end

      it 'redirects to the created user' do
        post users_url, params: { user: valid_attributes }
        expect(response).to redirect_to(user_url(User.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new User' do
        expect do
          post users_url, params: { user: invalid_attributes }
        end.not_to change(User, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post users_url, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { display_name: 'my new name' } }

      it 'updates the requested user' do
        user = User.create! valid_attributes
        patch user_url(user), params: { user: new_attributes }
        user.reload
        expect(user.display_name).to eq 'my new name'
      end

      it 'redirects to the admin_user' do
        user = User.create! valid_attributes
        patch user_url(user), params: { user: new_attributes }
        user.reload
        expect(response).to redirect_to(user_url(user))
      end

      it 'can update role associations', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        system_role = Role.find_by(name: 'System Manager')
        user_role = Role.find_by(name: 'User Manager')
        super_role = Role.find_by(name: 'Super Admin')

        expect(super_admin.roles).to contain_exactly(super_role)
        patch user_url(super_admin), params: { user: { role_ids: ['', user_role.id.to_s, system_role.id.to_s] } }
        super_admin.reload
        expect(super_admin.roles).to contain_exactly(user_role, system_role)
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        user = User.create! valid_attributes
        patch user_url(user), params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested admin_user' do
      user = User.create! valid_attributes
      expect do
        delete user_url(user)
      end.to change(User, :count).by(-1)
    end

    it 'redirects to the users list' do
      user = User.create! valid_attributes
      delete user_url(user)
      expect(response).to redirect_to(users_url)
    end
  end

  describe 'resctricts access' do
    example 'for guest users' do
      logout
      get users_url
      expect(response).to be_not_found
    end

    example 'for non-admin users' do
      login_as regular_user
      get users_url
      expect(response).to be_unauthorized
    end
  end
end
