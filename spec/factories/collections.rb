FactoryBot.define do
  factory :collection do
    blueprint
    metadata do
      {
        'Title' => 'Unremarkable Collection'
      }
    end
  end
end
