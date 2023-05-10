require 'rails_helper'

RSpec.describe 'configs/_fields_form' do
  context 'when in "host" setup step' do
    before do
      @config = Config.new(setup_step: 'host')
      render
    end

    it 'disables the field input' do
      expect(rendered).to have_field 'config[fields]', disabled: true
    end

    it 'does not have an update fields button' do
      expect(rendered).not_to have_button 'update_fields'
    end
  end

  context 'when in "fields" setup step' do
    before do
      @config = Config.new(setup_step: 'fields')
      render
    end

    it 'disables the field input' do
      expect(rendered).to have_field 'config[fields]'
    end

    it 'shows an update fields button' do
      expect(rendered).to have_button 'update_fields'
    end
  end
end
