module Api
    module V1
        class BoggleController < ApplicationController

            def findValidWordsFromMatrixData                
                begin
                    # render json: {status: 'ERROR', message: params[:matrix]}, status: :ok
                    word_to_valid = (params[:word])?(params[:word]).delete(' '):''
                    matrix_id = (params[:matrix_id])?params[:matrix_id] :''
                    matrix_value = (params[:matrix_value])?params[:matrix_value] :''
                    matrix_size = params[:size]?params[:size] :''
                    puzzle_instance = params[:puzzle_instance]?params[:puzzle_instance] :''

                    if word_to_valid.length < 3
                        render json: {status: 'ERROR', message: 'Must be 3 or more char'}, status: :ok
                        return
                    end

                    if(word_to_valid  === '' || matrix_value === '' || matrix_size ==='' || matrix_id ==='' || puzzle_instance ==='')
                        render json: {status: 'ERROR', message: 'Not a valid request'}, status: :ok
                        return
                    end
                    
                    matrix_data = generateWordMatrixArray(matrix_value,matrix_size,false)
                    matrix_data_state = generateWordMatrixArray(matrix_value,matrix_size,true)

                    response = boggle_search(matrix_data,matrix_data_state,word_to_valid,0,matrix_size,'',nil,nil)

                    validity_status = (response === 'found')?isValidWordDictionaryAPI(word_to_valid): 'invalid'
                    
                    payload = ''
                    message = (response === 'found') ? 'Found but Invalid.' : 'Invalid word.'

                    if(validity_status === 'valid')
                        payload = { 
                            word: word_to_valid, 
                            length: word_to_valid.length,
                            point: word_to_valid.length, 
                            word_matrix_id: matrix_id,
                            puzzle_instance: puzzle_instance
                        }
                        MatrixValidWord.create(payload)
                    end
                    
                    render json: {status: 'SUCCESS', message: message, payload: payload, validity: validity_status}, status: :ok
                rescue => exception
                    render json: {status: 'ERROR', message: 'Exception occured', payload: exception, validity: 'invalid'}, status: :ok
                end
            end

            private

            def getScoreByLength(length)
                return (length > 7) ? 11 : (length === 7) ? 5 : (length === 6 ) ? 3 : (length ===5)?2: (length < 5 && length > 2) ? 1 :0
            end

            def generateWordMatrixArray(matrix,matrix_size,state_matrix = true)
                
                matrix_arr=[]
                if state_matrix
                    for i in 0..(matrix_size-1) do
                      matrix = Array.new(matrix_size) {'N'}.join
                      matrix_arr[i] = matrix.split(//)
                    end                   
                else
                    for i in 0..(matrix_size-1) do
                        matrix_s = matrix[matrix_size*i,matrix_size]
                        matrix_arr[i] = matrix_s.split(//)
                    end 
                end
                return matrix_arr
            end

            def boggle_search(fgrid, fgrid_state, word, char_index, m_size, latest_word_found, lwf_index, false_index)
                
                if (latest_word_found === word)
                    return 'found'
                end
        
                if (word.length > m_size * m_size) 
                    return 'char_exceeded'
                end
        
                char_location_array = getCharsLocations(fgrid, m_size, m_size, word[latest_word_found.length])

                if(char_location_array === 0)
                    return 'not_found'
                end
        
                if (lwf_index != nil)
        
                    current_pos = [lwf_index[lwf_index.length - 1][0], lwf_index[lwf_index.length - 1][1]]
        
                    charExists = isCharExistInAnyDirections(fgrid, fgrid_state, m_size, word[latest_word_found.length], current_pos)
        
                    if (charExists != nil)
                        fgrid_state[charExists[0]][charExists[1]] = 'Y'
                        latest_word_found = latest_word_found + word[latest_word_found.length]
                        lwf_index.push(charExists)
                        return boggle_search(fgrid, fgrid_state, word, latest_word_found.length, m_size, latest_word_found, lwf_index, nil)
                    end
        
                    false_index = (false_index === nil) ? [] : false_index
                    false_index.push(current_pos)
                    lwf_index.pop()
                    latest_word_found = latest_word_found[0, latest_word_found.length - 1]
                    lwf_index = (lwf_index.length == 0) ? nil : lwf_index
                    char_index = (lwf_index == nil) ? char_index : latest_word_found.length
                    return boggle_search(fgrid, fgrid_state, word, char_index, m_size, latest_word_found, lwf_index, false_index)
        
                end
        
                for i in char_index..(char_location_array.length-1)

                    if (fgrid_state[char_location_array[i][0]][char_location_array[i][1]] != 'Y') 

                        charExists = isCharExistInAnyDirections(fgrid, fgrid_state, m_size, word[latest_word_found.length + 1], char_location_array[i])
        
                        if (charExists != nil)

                            fgrid_state[char_location_array[i][0]][char_location_array[i][1]] = 'Y'
                            lwf_index = []
                            lwf_index.push([char_location_array[i][0], char_location_array[i][1]])
                            lwf_index.push(charExists)
        
                            fgrid_state[charExists[0]][charExists[1]] = 'Y'
        
                            latest_word_found = fgrid[char_location_array[i][0]][char_location_array[i][1]] + word[latest_word_found.length + 1]
        
                            return boggle_search(fgrid, fgrid_state, word, char_index + 1, m_size, latest_word_found, lwf_index, nil)
                        end
                    end        
                end
                
                return 'not_found'
            end

            def getCharsLocations(fgrid,row,col,charc)
                v_word_indexes = [];
                for j in 0..(row-1)
                    for k in 0..(col-1)
                        if fgrid[j][k] === charc
                            v_word_indexes.push([j,k])
                        end
                    end
                end
				return v_word_indexes;
            end

            def isCharExistInAnyDirections(fgrid, fgrid_state, m_size, char_to_find, current_char_location)
                direction = [
                [1, 0], [1, 1], [0, 1], [-1, 1],
                [-1, 0], [-1, -1], [0, -1], [1, -1]
                ];

                for d in 0..direction.length-1
                    next_element_row = current_char_location[0] + direction[d][0]
                    next_element_col = current_char_location[1] + direction[d][1]

                    if (next_element_row >= 0 && next_element_col >= 0 && next_element_row <= (m_size - 1) && next_element_col <= (m_size - 1) && 
                        fgrid[next_element_row][next_element_col] === char_to_find && fgrid_state[next_element_row][next_element_col] != 'Y') 
                        return [next_element_row, next_element_col]
                    end                    
                end
                return nil
            end

            def isValidWordDictionaryAPI(word)
                api_key='dict.1.1.20200318T060530Z.d2bde6eef6075177.6f925999c467501a558dcabfaf27e01df29ad718'
                api_link='https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key='+api_key+'&lang=en-en'
                text = '&text='+word

                headers = { 'Accept' => 'application/json'}                
                response = RestClient.get(api_link+text,headers)
                json_res = JSON.parse response

                if json_res['def'] and json_res['def'].length > 0
                    return 'valid'
                else 
                    return 'invalid'
                end
            end
        end
    end
end