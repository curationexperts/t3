# Helpers to support selection and display of complex data types
module DataTypeHelper
  def data_type_options
    {
      'Core Types' => Field.data_types.except('vocabulary').keys.map { |k| [k, k] },
      'Local Vocabularies' => Vocabulary.pluck(:label, :id).sort.map { |label, id| [label, "vocabulary|#{id}"] }
    }
  end
end
