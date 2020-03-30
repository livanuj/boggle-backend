class CreateMatrixValidWords < ActiveRecord::Migration[6.0]
  def change
    create_table :matrix_valid_words do |t|
      t.string :word, limit: 30
      t.integer :length
      t.integer :point
      t.string :puzzle_instance, limit: 15

      t.references :word_matrix, index: true

      t.timestamps
    end
  end
end
