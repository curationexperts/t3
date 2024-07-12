# Custom form controls to support T3 field-specific data types
# e.g. #vacabulary provides a customized select populated with a defined vocabulary
class T3FormBuilder < ActionView::Helpers::FormBuilder
  # Render a select box with options populated from collection names
  # @param options [Hash]
  # @param html_options [hash]
  #   see #custom_select for common options
  def collection_field(method, options = {}, html_options = {})
    choices = Collection.all.map(&:label).sort
    custom_select(method, choices, options, html_options)
  end

  # Render a select box with options populated from a local vocabulary
  # @param options [Hash]
  #   :vocabualry - the vocabulary to display
  # @param html_options [hash]
  #   see #custom_select for other common options
  def vocabulary_field(method, options = {}, html_options = {})
    vocabulary = options.delete(:vocabulary)
    choices = vocabulary.terms.order(:label, :id).pluck(:label, :id)
    custom_select(method, choices, options, html_options)
  end

  # Render a custom dropdown that only allows only one option per input,
  # but can be rendered as part of a multi-value parameter if repeated
  # by the calling form.
  # @param options [Hash] primary options include
  #   :value - the option label (if any) that should be selected when initially rendered
  #   :multiple - flag whether this form parameter should be named as an individual field or part of an array []
  #   :prompt - defaults to 'Select one', accepts an alternate string, or pass `false` to suppress
  # @param html_options [hash]
  #   see Rails FormBuilder#select for additional options
  def custom_select(method, choices, options = {}, html_options = {})
    options[:selected] ||= options.delete(:value)
    multiple = options.delete(:multiple)
    suffix = options.delete(:suffix)
    options[:prompt] ||= 'Select one'
    html_options[:name] ||= @template.field_name(@object_name, method, multiple: multiple)
    html_options[:id] ||= @template.field_id(@object_name, method, suffix)

    select(method, choices, options, html_options)
  end
end
