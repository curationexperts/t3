class RenameVocabularyTermsToTerms < ActiveRecord::Migration[7.1]
  def change
    rename_table 'vocabulary_terms', 'terms'
  end
end
