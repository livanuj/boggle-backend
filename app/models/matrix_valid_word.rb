class MatrixValidWord < ApplicationRecord
    validates :word, presence: true
    validates :length, presence: true
    validates :point, presence: true
    validates :word_matrices_id, presence: true 
end
