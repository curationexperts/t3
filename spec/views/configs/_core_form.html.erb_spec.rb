require 'rails_helper'

RSpec.describe 'configs/_core_form' do
  context 'when in host setup step' do
    before do
      @config = Config.new(setup_step: 'host')
    end

    it 'disables the solr_core input field' do
      render
      expect(rendered).to have_field 'config[solr_core]', disabled: true
    end
  end

  context 'when in solr_core setup step' do
    before do
      @config = Config.new(setup_step: 'core')
      allow(@config).to receive(:available_cores).and_return(%w[core1 core2 core3]) # rubocop:disable RSpec/InstanceVariable
    end

    it 'enables the solr_core input field' do
      render
      expect(rendered).to have_select 'config[solr_core]', enabled_options: %w[core1 core2 core3],
                                                           disabled_options: ['Please choose a core']
    end
  end
end
