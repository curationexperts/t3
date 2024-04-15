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

  describe '#vocabulary' do
    let(:vocabulary_helper) { Capybara.string(form_builder.vocabulary_field(:collection, tag_options)) }

    it 'renders a select with the expected id' do
      expect(vocabulary_helper).to have_select('item[metadata][collection]')
    end

    it 'displays a prompt when no value is selected' do
      expect(vocabulary_helper).to have_selector('select option[selected]', text: 'Select one')
    end

    context 'with options {multipe: true}' do
      let(:tag_options) { { multiple: true } }

      it 'renders as an array instead of a multi-select' do
        expect(vocabulary_helper).to have_select('item[metadata][collection][]')
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
        select_options = vocabulary_helper.all('option').map(&:text)
        expect(select_options).to eq ['Select one', 'Red', 'Green', 'Blue']
      end

      example 'with a selection' do
        expect(vocabulary_helper).to have_selector('select option[selected]', text: 'Green')
      end
    end
  end
end
