require 'rails_helper'

RSpec.describe 'admin/fields/index.json.jbuilder' do
  let(:fields) { FactoryBot.create_list(:field, 3) }
  let(:json) { JSON.parse(render) }

  before { assign(:fields, fields) }

  it 'lists each field' do
    expect(json.pluck('name')).to eq [fields[0]['name'], fields[1]['name'], fields[2]['name']]
  end

  it 'includes all the attributes for each field' do
    expect(json[0].keys).to include(*Field.attribute_names)
  end
end
