module Api
    module V1     
        class MatrixValidWordsController < ApplicationController

            def  index
                matrix_valid_words = MatrixValidWord.order('created_at DESC')
                render json: {status:'SUCCESS', message:'Loaded valid words', payload: matrix_valid_words}, status: :ok                
            end

            def show
                matrix_valid_word = MatrixValidWord.find(params[:id])
                render json: {status:'SUCCESS', message:'Loaded valid word',payload:matrix_valid_word}, status: :ok           
            end

            def create
                matrix_valid_word = MatrixValidWord.new(valid_words_params)

                if matrix_valid_word.save
                    render json: {status:'SUCCESS', message:'Saved valid words', payload: matrix_valid_word}, status: :ok
                else
                    render json: {status:'ERROR', message:'Valid words not saved', payload: matrix_valid_word.errors}, status: :unprocessable_entity    
                end
            end

            private def valid_words_params
                params.permit(:word, :length, :point, :word_matrices_id)
            end
        end     
    end
end