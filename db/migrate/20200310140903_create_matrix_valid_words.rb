class CreateMatrixValidWords < ActiveRecord::Migration[6.0]
  def change
    create_table :matrix_valid_words do |t|
      t.string :word
      t.integer :length
      t.integer :point
      t.integer :rarity

      t.references :word_matrices, index: true

      t.timestamps
    end
  end
end
