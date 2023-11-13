FactoryBot.define do
  factory :item do
    blueprint
    description { '' }
  end

  factory :populated_item, class: 'Item' do
    blueprint factory: %i[blueprint_with_basic_fields]
    description do
      {
        'title' => 'One Hundred Years of Solitute',
        'author' => 'Márquez, Gabriel García',
        'date' => '1967'
      }
    end
  end
end
