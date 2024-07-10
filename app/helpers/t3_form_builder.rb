# Custom form controls to support T3 field-specific data types
# e.g. #vacabulary provides a customized select populated with a defined vocabulary
class T3FormBuilder < ActionView::Helpers::FormBuilder
  def collection_field(method, options = {})
    multiple = options.delete(:multiple)
    selected = options.delete(:value) || ''
    select_options = options.except(:multiple)
                            .reverse_merge(
                              { name: @template.field_name(@object_name, method, multiple: multiple) }
                            )
                            .merge({ selected: selected })
    option_tags = @template.options_from_collection_for_select(Collection.order(:created_at), :label, :label, selected)
    select(method, option_tags, { prompt: 'Select one', selected: '', disabled: true }, select_options)
  end

  # Render a slect box with options populated from a local vocabulary
  # @param options [Hash] primary options include
  #   :vocabualry - the vocabulary to display
  #   :selected - the current value for the input (must match the key of one of the vocabulary terms)
  #   :multiple - flag whether this form parameter should be named as an individual field or part of an array []
  #   :prompt - defaults to 'Select one', accepts an alternate string, or pass `false` to suppress
  #   see Rails FormBuilder#select for additional options
  def vocabulary_field(method, options = {}, html_options = {})
    vocabulary = options.delete(:vocabulary)
    multiple = options.delete(:multiple)
    html_options[:name] ||= @template.field_name(@object_name, method, multiple: multiple)
    options[:prompt] ||= 'Select one'
    choices = vocabulary.terms.order(:label, :key).map { |term| [term.label, term.key] }

    select(method, choices, options, html_options)
  end
end
