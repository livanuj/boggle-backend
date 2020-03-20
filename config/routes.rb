Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      resources :word_matrices do
          # get 'findValidWordsFromMatrixData' , on: :collection
      end
      resources :matrix_valid_words   
      post 'boggle/findValidWordsFromMatrixData', to: 'boggle#findValidWordsFromMatrixData'
      # get 'word_matrices/findValidWordsFromMatrixData', to: 'word_matrices#findValidWordsFromMatrixData'
    end
  end
end
