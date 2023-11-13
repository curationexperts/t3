require 'rails_helper'

RSpec.describe '/admin/items' do
  # This should return the minimal set of attributes required to create a valid
  # Item. As you add validations to Item, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { 'description' => { 'title' => 'My Title' }, 'blueprint_id' => Blueprint.first.id } }
  let(:invalid_attributes) { { blueprint_id: '' } }

  # Fake a minimal Solr server
  before do
    solr_client = RSolr::Client.new(nil)
    allow(RSolr::Client).to receive(:new).and_return(solr_client)
    allow(solr_client).to receive(:get).and_return({ 'lucene' => { 'solr-spec-version' => '9.4.0' } })
    allow(solr_client).to receive(:update)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Item.create(valid_attributes)
      get items_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      item = Item.create(valid_attributes)
      get item_url(item)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    context 'without a blueprint selected' do
      it 'renders a parital completion response' do
        get new_item_url
        expect(response).to be_successful
      end

      it 'renders the _choose_blueprint selection partial' do
        get new_item_url
        expect(response.body).to include('id=\'choose_blueprint\'')
      end
    end

    context 'with a blueprint selected' do
      let(:blueprint) { FactoryBot.create(:blueprint) }

      it 'renders a successful response' do
        get new_item_url, params: { blueprint_id: blueprint.id }
        expect(response).to be_successful
      end

      it 'renders the _form fields partial' do
        get new_item_url, params: { blueprint_id: blueprint.id }
        expect(response.body).to include('id="item_fields"')
      end
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      item = Item.create! valid_attributes
      get edit_item_url(item)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Item' do
        expect do
          post items_url, params: { item: valid_attributes }
        end.to change(Item, :count).by(1)
      end

      it 'redirects to the created item' do
        post items_url, params: { item: valid_attributes }
        expect(response).to redirect_to(item_url(Item.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Item' do
        expect do
          post items_url, params: { item: invalid_attributes }
        end.not_to change(Item, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post items_url, params: { item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        { description: valid_attributes['description'].merge({ 'alternate_title' => 'Weiterer Titel' }) }
      end

      it 'updates the requested item' do
        item = Item.create! valid_attributes
        patch item_url(item), params: { item: new_attributes }
        item.reload
        expect(item.description['alternate_title']).to eq 'Weiterer Titel'
      end

      it 'redirects to the item' do
        item = Item.create! valid_attributes
        patch item_url(item), params: { item: new_attributes }
        item.reload
        expect(response).to redirect_to(item_url(item))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        item = Item.create! valid_attributes
        patch item_url(item), params: { item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested item' do
      # item = Item.create! valid_attributes
      item = FactoryBot.create(:populated_item)
      expect do
        delete item_url(item)
      end.to change(Item, :count).by(-1)
    end

    it 'redirects to the items list' do
      # item = Item.create! valid_attributes
      item = FactoryBot.create(:populated_item)
      delete item_url(item)
      expect(response).to redirect_to(items_url)
    end
  end
end
