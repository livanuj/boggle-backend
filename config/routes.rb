Rails.application.routes.draw do

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      post 'word_matrices/getMatrixData', to: 'word_matrices#getMatrixData'
      post 'matrix_valid_words/getPuzzleStats', to: 'matrix_valid_words#getPuzzleStats'
      post 'boggle/findValidWordsFromMatrixData', to: 'boggle#findValidWordsFromMatrixData'
    end
  end
end
