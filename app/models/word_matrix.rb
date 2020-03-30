class WordMatrix < ApplicationRecord
    has_many :matrix_valid_words
    validates :matrix_value , presence: true
end
