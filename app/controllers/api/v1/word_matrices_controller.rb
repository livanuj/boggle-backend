module Api
    module V1
        class WordMatricesController < ApplicationController
            def index
                word_matrices = WordMatrix.order('created_at DESC')
                render json: {status:'SUCCESS', message:'Loaded word matrices', payload: word_matrices}, status: :ok
            end

            def show
                word_matrix = WordMatrix.find(params[:id])
                render json: {status:'SUCCESS', message:'Loaded word matrix',payload:word_matrix}, status: :ok           
            end

            def create
                word_matrix = WordMatrix.new(wmatrix_params)

                if word_matrix.save
                    render json: {status:'SUCCESS', message:'Saved word matrix', payload: word_matrix}, status: :ok
                else
                    render json: {status:'ERROR', message:'Word Matrix not saved', payload: word_matrix.errors}, status: :unprocessable_entity    
                end
            end

            private def wmatrix_params
                params.permit(:matrix_value)
            end

            def destroy 
                word_matrix = WordMatrix.find(params[:id])
                word_matrix.destroy
                render json: {status:'SUCCESS', message:'Deleted word matrix', payload: word_matrix}, status: :ok
            end

            def update
                word_matrix = WordMatrix.find(params[:id])
                
                if word_matrix.update_attributes(wmatrix_params)
                  render json: {status:'SUCCESS', message:'Updated word matrix', payload: word_matrix}, status: :ok
                else
                  render json: {status:'ERROR', message:'Word matrix not updated', payload: word_matrix.errors}, status: :unprocessable_entity
                end
            end

            def getMatrixData
                matrix_data = MatrixValidWord.where(word_matrices_id: 1)
                matrix_data = generateRandomWord(16)                
                render json: {status:'SUCCESS', message:'matrix data loaded', payload: matrix_data}, status: :ok
            end       

            private def generateRandomWord(length)
                return 'ONORCGFNNOTTNRIA'
                charset = Array('A'..'Z')
                word = Array.new(length) { charset.sample }.join
                return word
            end

        end
    end    
end