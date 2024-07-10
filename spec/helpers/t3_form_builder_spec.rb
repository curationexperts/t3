require 'rails_helper'

RSpec.describe T3FormBuilder do
  let(:form_builder) do
    described_class.new('item[metadata]',
                        OpenStruct.new({ 'Title' => 'Working Papers' }),
                        Object.extend(ActionView::Helpers::FormHelper,
                                      ActionView::Helpers::FormTagHelper, ActionView::Helpers::FormOptionsHelper),
                        {})
  end
  let(:tag_options) { {} }

  describe '#collection' do
    let(:collection_helper) { Capybara.string(form_builder.collection_field(:collection, tag_options)) }

    it 'renders a select with the expected id' do
      expect(collection_helper).to have_select('item[metadata][collection]')
    end

    it 'displays a prompt when no value is selected' do
      expect(collection_helper).to have_selector('select option[selected]', text: 'Select one')
    end

    context 'with options {multipe: true}' do
      let(:tag_options) { { multiple: true } }

      it 'renders as an array instead of a multi-select' do
        expect(collection_helper).to have_select('item[metadata][collection][]')
      end
    end

    describe 'displays options' do
      let(:tag_options) { { value: 'Green' } }

      before do
        collections = [
          instance_double(Collection, { label: 'Red', id: 5 }),
          instance_double(Collection, { label: 'Green', id: 20 }),
          instance_double(Collection, { label: 'Blue', id: 25 })
        ]
        allow(Collection).to receive(:order).and_return(collections)
      end

      example 'showing available collections' do
        select_options = collection_helper.all('option').map(&:text)
        expect(select_options).to eq ['Select one', 'Red', 'Green', 'Blue']
      end

      example 'with a selection' do
        expect(collection_helper).to have_selector('select option[selected]', text: 'Green')
      end
    end
  end

  describe '#vocabulary' do
    let(:vocabulary) { FactoryBot.create(:vocabulary) }
    let(:tag_options) { { vocabulary: vocabulary } }
    let(:vocabulary_helper) { Capybara.string(form_builder.vocabulary_field('Resource Type', tag_options)) }

    it 'renders a select with the expected id' do
      expect(vocabulary_helper).to have_select('item[metadata][Resource Type]')
    end

    it 'displays a prompt when no value is selected' do
      expect(vocabulary_helper).to have_selector('select option', text: 'Select one')
    end

    context 'with options {multipe: true}' do
      let(:tag_options) { { vocabulary: vocabulary, multiple: true } }

      it 'renders as an array instead of a multi-select' do
        expect(vocabulary_helper).to have_select('item[metadata][Resource Type][]')
      end
    end

    describe 'displays options' do
      before do
        FactoryBot.create(:term, label: 'γάμμα', key: 'gamma', vocabulary: vocabulary)
        FactoryBot.create(:term, label: 'άλφα', key: 'alpha', vocabulary: vocabulary)
        FactoryBot.create(:term, label: 'βήτα་', key: 'beta', vocabulary: vocabulary)
      end

      example 'for each vocabulary term sorted lexically' do
        select_options = vocabulary_helper.all('option').map(&:text)
        expect(select_options).to eq ['Select one', 'άλφα', 'βήτα་', 'γάμμα']
      end

      example 'with a term selected' do
        tag_options[:selected] = 'beta'
        expect(vocabulary_helper).to have_selector('select option[selected]', text: 'βήτα')
      end
    end
  end
end
