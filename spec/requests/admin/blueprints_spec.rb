require 'rails_helper'

RSpec.describe '/admin/blueprints' do
  # This should return the minimal set of attributes required to create a valid
  # Blueprint. As you add validations to Blueprint, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    FactoryBot.attributes_for(:blueprint)
  end
  let(:invalid_attributes) do
    FactoryBot.attributes_for(:blueprint, name: 'Special Characters: ! <>')
  end
  let(:super_admin)  { FactoryBot.create(:super_admin) }
  let(:regular_user) { FactoryBot.create(:user) }

  before { login_as super_admin }

  describe 'GET /index' do
    it 'renders a successful response' do
      Blueprint.create! valid_attributes
      get blueprints_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      blueprint = Blueprint.create! valid_attributes
      get blueprint_url(blueprint)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_blueprint_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      blueprint = Blueprint.create! valid_attributes
      get edit_blueprint_url(blueprint)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Blueprint' do
        expect do
          post blueprints_url, params: { blueprint: valid_attributes }
        end.to change(Blueprint, :count).by(1)
      end

      it 'redirects to the created blueprint' do
        post blueprints_url, params: { blueprint: valid_attributes }
        expect(response).to redirect_to(blueprint_url(Blueprint.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Blueprint' do
        expect do
          post blueprints_url, params: { blueprint: invalid_attributes }
        end.not_to change(Blueprint, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post blueprints_url, params: { blueprint: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: Faker::Alphanumeric.alphanumeric } }

      it 'updates the requested blueprint' do
        blueprint = Blueprint.create! valid_attributes
        patch blueprint_url(blueprint), params: { blueprint: new_attributes }
        blueprint.reload
        expect(blueprint.name).to eq new_attributes[:name]
      end

      it 'redirects to the blueprint' do
        blueprint = Blueprint.create! valid_attributes
        patch blueprint_url(blueprint), params: { blueprint: new_attributes }
        blueprint.reload
        expect(response).to redirect_to(blueprint_url(blueprint))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        blueprint = Blueprint.create! valid_attributes
        patch blueprint_url(blueprint), params: { blueprint: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested blueprint' do
      blueprint = Blueprint.create! valid_attributes
      expect do
        delete blueprint_url(blueprint)
      end.to change(Blueprint, :count).by(-1)
    end

    it 'redirects to the blueprints list' do
      blueprint = Blueprint.create! valid_attributes
      delete blueprint_url(blueprint)
      expect(response).to redirect_to(blueprints_url)
    end
  end

  describe 'resctricts access' do
    example 'for guest users' do
      logout
      get blueprints_url
      expect(response).to be_not_found
    end

    example 'for non-admin users' do
      login_as regular_user
      get blueprints_url
      expect(response).to be_unauthorized
    end
  end
end
