module Api
    module V1
        class WordMatricesController < ApplicationController
            def index
                word_matrices = WordMatrix.order('created_at DESC')
                render json: {status:'SUCCESS', message:"Loaded word matrices", payload: word_matrices}, status: :ok
            end

            def create
                word_matrix
            end
        end
    end    
end

