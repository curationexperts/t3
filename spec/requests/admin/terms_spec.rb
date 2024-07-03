require 'rails_helper'

RSpec.describe 'admin/terms' do
  let(:test_vocab) { Vocabulary.find_or_create_by(label: 'Admin/Terms Test Vocabulary') }
  let(:valid_attributes) { FactoryBot.attributes_for(:term, vocabulary_id: test_vocab.id) }
  let(:invalid_attributes) do
    FactoryBot.attributes_for(:term, vocabulary_id: test_vocab.id, slug: '<Invalid $lug!>')
  end
  let(:super_admin)  { FactoryBot.create(:super_admin) }
  let(:regular_user) { FactoryBot.create(:user) }

  before { login_as super_admin }

  describe 'GET /index' do
    it 'renders a successful response' do
      Term.create! valid_attributes
      get vocabulary_terms_url(test_vocab)
      expect(response).to be_successful
    end

    it 'appears under the status navigation menu' do
      get vocabulary_terms_url(test_vocab)
      page = Capybara.string(response.body)
      expect(page).to have_link(href: vocabularies_path, class: 'nav-link active')
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      term = Term.create! valid_attributes
      get term_url(term)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_vocabulary_term_url(test_vocab)
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      term = Term.create! valid_attributes
      get edit_term_url(term)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Term' do
        expect do
          post vocabulary_terms_url(test_vocab), params: { term: valid_attributes }
        end.to change(Term, :count).by(1)
      end

      it 'redirects to the created term' do
        post vocabulary_terms_url(test_vocab), params: { term: valid_attributes }
        expect(response).to redirect_to(term_url(Term.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Term' do
        expect do
          post vocabulary_terms_url(test_vocab), params: { term: invalid_attributes }
        end.not_to change(Term, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post vocabulary_terms_url(test_vocab), params: { term: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:new_attributes) do
        { note: 'Usage notes go here...' }
      end

      it 'updates the requested term' do
        term = Term.create! valid_attributes
        patch term_url(term), params: { term: new_attributes }
        term.reload
        expect(term.note).to eq 'Usage notes go here...'
      end

      it 'redirects to the term' do
        term = Term.create! valid_attributes
        patch term_url(term), params: { term: new_attributes }
        term.reload
        expect(response).to redirect_to(term_url(term))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { slug: '<Invalid $lug!>' } }

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        term = Term.create! valid_attributes
        patch term_url(term), params: { term: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested term' do
      term = Term.create! valid_attributes
      expect do
        delete term_url(term)
      end.to change(Term, :count).by(-1)
    end

    it 'redirects to the terms list' do
      term = Term.create! valid_attributes
      delete term_url(term)
      expect(response).to redirect_to(vocabulary_terms_url(test_vocab))
    end
  end

  describe 'resctricts access' do
    example 'for guest users' do
      logout
      get vocabulary_terms_url(test_vocab)
      expect(response).to be_not_found
    end

    example 'for non-admin users' do
      login_as regular_user
      get vocabulary_terms_url(test_vocab)
      expect(response).to be_unauthorized
    end
  end
end
