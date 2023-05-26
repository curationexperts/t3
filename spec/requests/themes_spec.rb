require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/themes' do
  # This should return the minimal set of attributes required to create a valid
  # Theme. As you add validations to Theme, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { label: 'Test Theme' } }

  let(:invalid_attributes) do
    skip 'wait until the class requires some type of validation'
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Theme.create! valid_attributes
      get themes_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      theme = Theme.create! valid_attributes
      get theme_url(theme)
      expect(response).to be_successful
    end

    it 'renders as CSS when requested' do
      theme = Theme.create! valid_attributes
      get theme_url(theme, format: :css)
      expect(response.content_type).to eq 'text/css; charset=utf-8'
    end
  end

  describe 'GET /current' do
    it 'displays the active theme' do
      get theme_url('current')
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_theme_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      theme = Theme.create! valid_attributes
      get edit_theme_url(theme)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Theme' do
        expect do
          post themes_url, params: { theme: valid_attributes }
        end.to change(Theme, :count).by(1)
      end

      it 'redirects to the created theme' do
        post themes_url, params: { theme: valid_attributes }
        expect(response).to redirect_to(theme_url(Theme.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Theme' do
        expect do
          post themes_url, params: { theme: invalid_attributes }
        end.not_to change(Theme, :count)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post themes_url, params: { theme: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { site_name: 'My New Site!' } }

      it 'updates the requested theme' do
        theme = Theme.create! valid_attributes
        patch theme_url(theme), params: { theme: new_attributes }
        theme.reload
        expect(theme.site_name).to eq 'My New Site!'
      end

      it 'redirects to the theme' do
        theme = Theme.create! valid_attributes
        patch theme_url(theme), params: { theme: new_attributes }
        theme.reload
        expect(response).to redirect_to(theme_url(theme))
      end
    end

    context 'with logos attached', :aggregate_failures do
      let(:logo) { fixture_file_upload('sample_logo.png') }
      let(:theme) { Theme.create! valid_attributes }

      it 'adds the logo' do
        expect(theme.main_logo).not_to be_attached
        patch theme_url(theme), params: { theme: { main_logo: logo } }
        theme.reload
        expect(theme.main_logo).to be_attached
      end

      it 'purges any existing logo' do # rubocop:disable RSpec/ExampleLength
        theme.main_logo.attach(logo)
        old_logo_blob = theme.main_logo.blob
        patch theme_url(theme), params: { theme: { main_logo: logo } }
        theme.reload
        expect(theme.main_logo.blob).not_to eq old_logo_blob
        expect { old_logo_blob.reload }.to raise_exception ActiveRecord::RecordNotFound
      end

      it 'remain attached when params are empty' do
        theme.main_logo.attach(logo)
        patch theme_url(theme), params: { theme: { site_name: 'New Site' } }
        theme.reload
        expect(theme.main_logo).to be_attached
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        theme = Theme.create! valid_attributes
        patch theme_url(theme), params: { theme: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /activate' do
    let(:theme) { Theme.create! valid_attributes }
    let(:patched) { Theme.new valid_attributes }

    it 'calls #activate! on the theme' do
      allow(Theme).to receive(:find).and_return(patched)
      allow(patched).to receive(:activate!)
      patch activate_theme_url(theme)
      expect(patched).to have_received(:activate!)
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested theme' do
      theme = Theme.create! valid_attributes
      expect do
        delete theme_url(theme)
      end.to change(Theme, :count).by(-1)
    end

    it 'redirects to the themes list' do
      theme = Theme.create! valid_attributes
      delete theme_url(theme)
      expect(response).to redirect_to(themes_url)
    end
  end
end
