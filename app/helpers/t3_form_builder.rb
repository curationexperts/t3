# Custom form controls to support T3 field-specific data types
# e.g. #vacabulary provides a customized select populated with a defined vocabulary
class T3FormBuilder < ActionView::Helpers::FormBuilder
  def vocabulary_field(method, options = {})
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
end
