class MatrixValidWord < ApplicationRecord
    belongs_to :word_matrix
    validates :word, presence: true
    validates :length, presence: true
    validates :point, presence: true    
end
