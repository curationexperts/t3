FactoryBot.define do
  factory :field do
    sequence(:name) { |n| "Field #{n}" }
    data_type { 1 }
    active { true }
    required { false }
    multiple { false }
    list_view { false }
    item_view { true }
    searchable { true }
    facetable { false }
  end
end
