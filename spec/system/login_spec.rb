require 'rails_helper'

RSpec.describe 'Login' do
  let(:user)  { FactoryBot.create(:user,        password: 'password') }
  let(:admin) { FactoryBot.create(:super_admin, password: 'password') }

  # Stub out Solr service
  before do
    solr_response = { responseHeader: { status: 0, QTime: 60, params: { rows: '10', wt: 'json' } },
                      response: { numFound: 0, start: 0, maxScore: 0.0, numFoundExact: true, docs: [] },
                      facet_counts: { facet_fields: { active_fedora_model_ssi: [], subject_ssim: [] },
                                      facet_queries: {}, facet_ranges: {}, facet_intervals: {} } }
    solr_client = instance_double RSolr::Client
    allow(RSolr).to receive(:connect).and_return(solr_client)
    allow(solr_client).to receive(:get).and_return solr_response
    allow(solr_client).to receive(:send_and_receive).and_return solr_response
  end

  it 'redirects administrators to the status page' do
    visit new_user_session_path
    fill_in 'user_email', with: admin.email
    fill_in 'user_password', with: 'password'
    click_on 'Log in'
    expect(page).to have_current_path status_path
  end

  it 'redirects regular users to root' do
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Log in'
    expect(page).to have_current_path root_path
  end

  it 'sets current_sign_in_at', :aggregate_failures do
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Log in'
    expect(user.reload.current_sign_in_at).to be_within(1.second).of(Time.now.utc)
  end
end
