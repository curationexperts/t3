class PopulateSlugsInVocabularies < ActiveRecord::Migration[7.1]
  def up
    # Ensure each vocabluary has a valid slug
    Vocabulary.find_each do |vocabulary|
      # Calling the validation will populate the slug if it's missing
      if vocabulary.invalid?
        # If the validation fails (presumably because the name can't be converted into a valid tag),
        # Create a tag based on only the alpha characters in the name
        # adding a prefix to flag and disambiguate the new slugs
        vocabulary.tag = vocabulary.name.gsub(/[^[[:alpha:]] -]/, '-').parameterize.prepend('migrated-')
      end
      vocabulary.save! # will save if the tag has been updated through validation or explicit assignment
    end
  end
end
