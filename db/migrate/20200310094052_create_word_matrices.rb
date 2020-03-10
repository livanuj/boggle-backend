class CreateWordMatrices < ActiveRecord::Migration[6.0]
  def change
    create_table :word_matrices do |t|
      t.string :matrix_value

      t.timestamps
    end
  end
end
