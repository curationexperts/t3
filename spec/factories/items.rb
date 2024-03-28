FactoryBot.define do
  factory :item do
    blueprint
    description do
      {
        'Title' => 'One Hundred Years of Solitute',
        'Author' => ['Márquez, Gabriel García'],
        'Date' => '1967'
      }
    end
  end
end
