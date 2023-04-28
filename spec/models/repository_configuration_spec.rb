require 'rails_helper'

RSpec.describe RepositoryConfiguration, :aggregate_failures do
  it 'accepts nested ConfigFields' do # rubocop:disable  RSpec/ExampleLength
    config = described_class.new(fields_attributes:
                                   { field1: { name: 'title_tsi', show: true },
                                     field2: { name: 'description_tesim', index: true } })
    field1 = config.fields[0]
    field2 = config.fields[1]
    expect(config.fields.count).to eq 2
    expect(field1).to be_a ConfigField
    expect(field1.name).to eq 'title_tsi'
    expect(field2.show).to be false
    expect(field2.index).to be true
  end

  describe 'persistence' do
    example '#load_config' do
      described_class.load_config('spec/fixtures/fields.json')
      config = described_class.current
      expect(config.fields[0].as_json).to include({ 'name' => 'title_tsi' })
      expect(config.fields[4].as_json).to include({ 'label' => 'Keywords' })
    end

    example '#save_config' do
      pending 'implementation of method'
      described_class.current.save_config('tmp/fields.json')
      expect(config.fields[0].as_json).to include({ 'name' => 'title_tsi' })
      expect(config.fields[4].as_json).to include({ 'label' => 'Keywords' })
    end
  end
end
