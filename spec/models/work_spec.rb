require 'rails_helper'

RSpec.describe Work do
  let(:new_work) { described_class.new }
  let(:basic_description) do
    {
      'identifier' => 'Test001',
      'title' => 'One Hundred Years of Solitute',
      'author' => 'Márquez, Gabriel García',
      'date' => '1967'
    }
  end

  describe '#description' do
    it 'defaults to nil' do
      expect(new_work.description).to be_nil
    end

    it 'accepts JSON' do
      new_work.description = basic_description.as_json
      expect(new_work.description['date']).to eq '1967'
    end
  end

  describe '#blueprint' do
    it 'must have a value' do
      new_work.blueprint = nil
      expect(new_work).not_to be_valid
    end

    it 'must be a kind of Blueprint' do
      expect { new_work.blueprint = 'not a blueprint' }.to raise_exception ActiveRecord::AssociationTypeMismatch
    end

    it 'must refer to an existing Blueprint' do
      placeholder = FactoryBot.create(:blueprint)
      work = described_class.new(blueprint: placeholder)
      expect { work.save! }.not_to raise_exception
    end
  end

  describe '#to_solr' do
    let(:solr_doc) do
      {
        'blueprint_ssi' => 'basic_metadata_mapping',
        'id' => 'Test001',
        'title_tesi' => 'One Hundred Years of Solitute',
        'author_tesim' => 'Márquez, Gabriel García',
        'date_dtsi' => '1967'
      }
    end

    it 'renders a solr document' do
      new_work.description = basic_description.as_json
      new_work.blueprint = FactoryBot.create(:core_blueprint)
      expect(new_work.to_solr).to eq solr_doc
    end
  end
end
