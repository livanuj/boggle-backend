class CreateWordMatrices < ActiveRecord::Migration[6.0]
  def change
    create_table :word_matrices do |t|
      t.string :matrix_value, limit: 30

      t.timestamps
    end
  end
end
