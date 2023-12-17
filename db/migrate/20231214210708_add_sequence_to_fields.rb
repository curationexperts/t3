class AddSequenceToFields < ActiveRecord::Migration[7.0]
  def change
    add_column :fields, :sequence, :integer
    add_index :fields, :sequence

    reversible do |direction|
      direction.up do
        # add a sequence number to each row
        execute <<-SQL.squish
          WITH Sequence AS (SELECT id, ROW_NUMBER() OVER(ORDER BY id) FROM fields)#{' '}
          UPDATE fields SET sequence = Sequence.row_number FROM Sequence WHERE fields.id = Sequence.id
        SQL
      end
    end
  end
end
