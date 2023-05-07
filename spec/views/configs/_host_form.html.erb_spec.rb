require 'rails_helper'

RSpec.describe 'configs/_host_form' do
  context 'without a verified host' do
    before do
      @config = Config.new(setup_step: 'host')
    end

    it 'enables the host input field' do
      render
      expect(rendered).to have_field 'config[solr_host]'
    end

    it 'has a verify host button' do
      render
      expect(rendered).to have_button 'verify_host'
    end
  end

  context 'with a verified host' do
    before do
      @config = Config.new(setup_step: 'core')
    end

    it 'disables the host input field' do
      render
      expect(rendered).to have_field 'config[solr_host]', disabled: true
    end

    it 'disables the verification button' do
      render
      expect(rendered).to have_button 'verify_host', disabled: true
    end
  end
end
