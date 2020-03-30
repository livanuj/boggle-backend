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

            def getPuzzleStats
                begin
                    word_matrix_id = params[:word_matrix_id]

                    isValidWordExists = (MatrixValidWord.where({word_matrix_id: word_matrix_id}).count > 0) ? true :false

                    played_times = (!isValidWordExists)? 0: MatrixValidWord.where({word_matrix_id: word_matrix_id}).distinct.count(:puzzle_instance)
                    high_score = (!isValidWordExists)? 0: MatrixValidWord.where({word_matrix_id: word_matrix_id}).group(:puzzle_instance).sum(:point).max_by{|k,v| v}.last
                    most_words = (!isValidWordExists)? 0: MatrixValidWord.where({word_matrix_id: word_matrix_id}).group(:puzzle_instance).count.max_by{|k,v| v}.last
                    max_length = (!isValidWordExists)? 0: MatrixValidWord.where({word_matrix_id: word_matrix_id}).map(&:length).max
                    longest_word =  (!isValidWordExists)? '': MatrixValidWord.where({word_matrix_id: word_matrix_id}).find_by(length: max_length ).word

                    payload = {played_times: played_times, high_score: high_score, most_words: most_words,longest_word: longest_word}
                    render json: {status:'SUCCESS', message:'Loaded puzzle stats', payload: payload }, status: :ok
                rescue => exception
                    render json: {status: 'ERROR', message: 'Exception occured', payload: exception}, status: :ok
                end
            end
        end     
    end
end