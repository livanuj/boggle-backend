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

            def getMatrixData
                begin
                    size = params[:size] ? params[:size] : 4
                    
                    #New boggle matrix or existing one
                    payload = ''
                    boggle_value = ['new','exist'].shuffle.first
                    puzzle_instance = generateRandomWord(15,true)

                    if( boggle_value === 'exist')
                        word_matrix = WordMatrix.all.sample  
                        payload = {word_matrix_id: word_matrix.id, matrix_value: word_matrix.matrix_value, size: size, puzzle_instance: puzzle_instance}
                    else
                        matrix_data = generateRandomWord(size*size,false)     
                        word_matrix = WordMatrix.create({matrix_value: matrix_data})  
                        payload = {word_matrix_id: word_matrix.id, matrix_value: word_matrix.matrix_value, size: size, puzzle_instance: puzzle_instance}
                    end                    
                    render json: {status:'SUCCESS', message:'Data loaded', payload: payload}, status: :ok
                rescue => exception
                    render json: {status:'ERROR', message:'Error loading data.', payload: exception}, status: :ok    
                end
               
            end       

            private 
            def generateRandomWord(length, alphaNum)
                # return 'ONORCGFNNOTTNRIA'
                charset = alphaNum ? Array('0'..'9') + Array('a'..'z') : Array('A'..'Z')
                word = Array.new(length) { charset.sample }.join
                return word
            end
            
            def wmatrix_params
                params.permit(:matrix_value)
            end

        end
    end    
end