require 'rails_helper'

RSpec.describe '/admin/collections' do
  # This should return the minimal set of attributes required to create a valid
  # Collection. As you add validations to Collection, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { 'metadata' => { 'title' => 'My Collection' }, 'blueprint_id' => Blueprint.first.id } }
  let(:invalid_attributes) { valid_attributes.except('blueprint_id') }
  let(:super_admin) { FactoryBot.create(:super_admin) }

  before do
    login_as super_admin

    # Fake a minimal Solr server
    solr_client = RSolr::Client.new(nil)
    allow(RSolr::Client).to receive(:new).and_return(solr_client)
    allow(solr_client).to receive(:get).and_return({ 'lucene' => { 'solr-spec-version' => '9.4.0' } })
    allow(solr_client).to receive(:update)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Collection.create(valid_attributes)
      get collections_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      collection = Collection.create(valid_attributes)
      get collection_url(collection)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    context 'without a blueprint selected' do
      it 'renders a parital completion response' do
        get new_collection_url
        expect(response).to be_successful
      end

      it 'renders the _choose_blueprint selection partial' do
        get new_collection_url
        expect(response.body).to include('id="choose_blueprint"')
      end
    end

    context 'with a blueprint selected' do
      it 'renders a successful response' do
        get new_blueprinted_collections_path(Blueprint.first.name)
        expect(response).to be_successful
      end

      it 'renders the _form fields partial' do
        get new_blueprinted_collections_path(Blueprint.first.name)
        expect(response.body).to include('id="item_fields"')
      end
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      collection = Collection.create! valid_attributes
      get edit_collection_url(collection)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Collection' do
        expect do
          post collections_url, params: { item: valid_attributes }
        end.to change(Collection, :count).by(1)
      end

      it 'redirects to the created Collection' do
        post collections_url, params: { item: valid_attributes }
        expect(response).to redirect_to(collection_url(Collection.last))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { valid_attributes.except('blueprint_id') }

      it 'does not create a new Collection' do
        expect do
          post collections_url, params: { item: invalid_attributes }
        end.not_to change(Collection, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post collections_url, params: { item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        { metadata: valid_attributes['metadata'].merge({ 'alternate_title' => 'Weiterer Titel' }) }
      end

      it 'updates the requested collection' do
        collection = Collection.create! valid_attributes
        patch collection_url(collection), params: { item: new_attributes }
        collection.reload
        expect(collection.metadata['alternate_title']).to eq 'Weiterer Titel'
      end

      it 'redirects to the Collection' do
        collection = Collection.create! valid_attributes
        patch collection_url(collection), params: { item: new_attributes }
        collection.reload
        expect(response).to redirect_to(collection_url(collection))
      end
    end

    context 'with a field refresh' do
      let(:collection) { FactoryBot.create(:collection, blueprint: blueprint) }
      let(:blueprint) { FactoryBot.build(:blueprint) }

      before do
        active = instance_double(ActiveRecord::Relation)
        allow(Field).to receive(:active).and_return(active)
        allow(active).to receive(:order).and_return(
          [FactoryBot.build(:field, name: 'Author', multiple: true)]
        )
      end

      it 'extends requested fields', :aggregate_failures do
        collection.metadata.merge!({ 'Author' => ['Bronte, Charlotte', 'Bell, Currer'] })
        patch collection_url(collection), params: { refresh: 'add Author -1', item: { metadata: collection.metadata } }
        body = Capybara.string(response.body)
        expect(body).to have_field('collection_metadata_Author_2', with: 'Bell, Currer')
        expect(body).to have_field('collection_metadata_Author_3') # field exists
        # expect(body).not_to have_field('collection_metadata_Author_3', with: /.*/) # and field is empty
      end

      it 'deletes requested fields', :aggregate_failures do
        collection.metadata.merge!({ 'Author' => ['Bronte, Charlotte', 'Bell, Currer'] })
        patch collection_url(collection), params:
          { refresh: 'delete Author 1', item: { metadata: collection.metadata } }
        body = Capybara.string(response.body)
        expect(body).to have_field('collection_metadata_Author_1', with: 'Bell, Currer')
        expect(body).to have_field('collection[metadata][Author][]', count: 1)
      end

      it 'refreshes data without saving' do
        patch collection_url(collection), params:
          { refresh: ['add', 'Author', '-1'].join(' '), item: { metadata: collection.metadata } }
        expect(response).to have_http_status(:accepted)
      end

      it 'handles delete on empty fields', :aggregate_failures do
        patch collection_url(collection),
              params: { refresh: ['delete', 'Author', '1'].join(' '),
                        item: { metadata: collection.metadata.except('Author') } }
        body = Capybara.string(response.body)
        expect(body).to have_button('refresh', value: 'delete Author 1')
        expect(response).to have_http_status(:accepted)
      end

      it 'rejects bad requests' do
        patch collection_url(collection),
              params: { refresh: ['delete', 'Author', '40'].join(' '), item: { metadata: collection.metadata } }
        expect(response).to have_http_status(:bad_request)
      end

      it 'handles field names that include spaces', :aggregate_failures do
        allow(Field.active).to receive(:order).and_return([FactoryBot.build(:field, name: 'Resource Type',
                                                                                    multiple: true)])
        patch collection_url(collection), params: {
          refresh: 'add Resource Type -1', item: { metadata: collection.metadata }
        }
        body = Capybara.string(response.body)
        expect(body).to have_selector('input#collection_metadata_Resource\ Type_2') # by id
        expect(body).to have_field('collection[metadata][Resource Type][]', count: 2) # by name
      end
    end

    context 'with invalid parameters' do
      let(:collection) { Collection.create! valid_attributes }

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        allow(collection).to receive(:update).and_return false
        allow(Collection).to receive(:find).and_return collection
        patch collection_url(collection), params: { item: valid_attributes.merge { 'metadata' => '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested collection' do
      collection = FactoryBot.create(:collection)
      expect do
        delete collection_url(collection)
      end.to change(Collection, :count).by(-1)
    end

    it 'redirects to the Collections list' do
      collection = FactoryBot.create(:collection)
      delete collection_url(collection)
      expect(response).to redirect_to(collections_url)
    end
  end

  describe 'resctricts access' do
    let(:regular_user) { FactoryBot.create(:user) }

    example 'for guest users' do
      logout
      get collections_url
      expect(response).to be_not_found
    end

    example 'for non-admin users' do
      login_as regular_user
      get collections_url
      expect(response).to be_unauthorized
    end
  end
end
