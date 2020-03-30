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
                        render json: {status: 'ERROR', message: 'Must be 3 or more char.'}, status: :ok
                        return
                    end

                    if(word_to_valid  === '' || matrix_value === '' || matrix_size ==='' || matrix_id ==='' || puzzle_instance ==='')
                        render json: {status: 'ERROR', message: 'Not a valid request'}, status: :ok
                        return
                    end
                    
                    matrix_data = generateWordMatrixArray(matrix_value,matrix_size,false)
                    matrix_data_state = generateWordMatrixArray(matrix_value,matrix_size,true)

                    response = boggle_search(matrix_data,matrix_data_state,word_to_valid,0,matrix_size,matrix_size,'',-1,-1,0)
                    validity_status = (response === 'found')?isValidWordDictionaryAPI(word_to_valid): 'invalid'
                    
                    payload = ''

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
                    
                    render json: {status: 'SUCCESS', message: validity_status.capitalize()+' word', payload:payload,validity: validity_status}, status: :ok
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

            def boggle_search(fgrid,fgrid_state,word,word_char_index,row,col,latest_word_found,prev_found_row,prev_found_col,char_location)

                v_word_arr = word.split(//)

                if(v_word_arr.length > (row*col))
                    return 'chars_exceeded'
                end

                if (word.length === latest_word_found.length && word === latest_word_found)
                    return 'found'
                end

                v_word = ''
                v_whole_word = ''

                direction = [
                    [1,0],[1,1],[0,1],[-1,1],
                    [-1,0],[-1,-1],[0,-1],[1,-1]
                ];

                v_word_arr_length = v_word_arr.length
                v_word = v_word_arr[word_char_index]
                
                #check chars location one at time
                v_word_indexes = getCharsLocations(fgrid,row,col,v_word)

                if (prev_found_row > -1 && prev_found_col > -1) #pre_index_found_start
                    for d in 0..(direction.length-1)
                        next_element_row = prev_found_row+ direction[d][0]
                        next_element_col = prev_found_col + direction[d][1]

                        if(next_element_row < 0 || next_element_col < 0 || next_element_row > (row-1) || next_element_col > (col-1))
                            d='invalid_direction'                                           
                        else
                            if (v_word_arr[word_char_index+1] === fgrid[next_element_row][next_element_col] && fgrid_state[next_element_row][next_element_col]!= 'Y')
                                fgrid_state[next_element_row][next_element_col] = 'Y'
                                latest_word_found = latest_word_found + v_word_arr[word_char_index+1] 
                                return boggle_search(fgrid,fgrid_state,word,word_char_index+1,row,col,latest_word_found,next_element_row,next_element_col,char_location)
                            end
                        end
                    end

                    if ((latest_word_found[latest_word_found.length - 1, 1] === latest_word_found[latest_word_found.length - 2, 1]) && ([0,(row-1)].include? prev_found_row) && ( [0,(col-1)].include? prev_found_col))
                            for d in 0..(direction.length-1)
                                next_element_row = prev_found_row+ direction[d][0];
                                next_element_col = prev_found_col + direction[d][1];

                                if (next_element_row < 0 || next_element_col < 0 || next_element_row > (row-1) || next_element_col > (col-1))
                                    d='invalid_direction'
                                else
                                    if (fgrid[next_element_row][next_element_col] === fgrid[prev_found_row][prev_found_col])
                                        fgrid_state[next_element_row][next_element_col] = 'N'
                                    end
                                end
                            end

                            latest_word_found = latest_word_found.substring(0, latest_word_found.length - 1)					
                            return boggle_search(fgrid,fgrid_state,word,word_char_index-1,row,col,latest_word_found,prev_found_row ,prev_found_col,char_location)
                    else
                        fgrid_state[prev_found_row][prev_found_col] = 'N'
                        latest_word_found = latest_word_found[0, latest_word_found.length - 1]
                        return boggle_search(fgrid,fgrid_state,word,word_char_index-1,row,col,latest_word_found,-1,-1,char_location)
                    end
                end #pre_index_found_end
               
                #check directions_from_initial_chars for_start
                chr = char_location
                for chr in 0..(v_word_indexes.length-1)
                    if(fgrid_state[v_word_indexes[chr][:row]][v_word_indexes[chr][:col]] !='Y')		

                        fgrid_state[v_word_indexes[chr][:row]][v_word_indexes[chr][:col]] = 'Y'

                        for d in 0..(direction.length-1) #start for

                            next_element_row = v_word_indexes[chr][:row] + direction[d][0]
                            next_element_col = v_word_indexes[chr][:col] + direction[d][1]

                            if (next_element_row < 0 || next_element_col < 0 || next_element_row > (row-1) || next_element_col > (col-1))
                                d='invalid_direction'
                            else

                                if (v_word_arr[word_char_index+1] === fgrid[next_element_row][next_element_col])

                                    fgrid_state[next_element_row][next_element_col] = 'Y'
                                    latest_word_found = v_word_arr[word_char_index] + v_word_arr[word_char_index+1]
                                    return boggle_search(fgrid,fgrid_state,word,word_char_index+1,row,col,latest_word_found,next_element_row,next_element_col,char_location+1)
                                end
                            end 
                        end #end for
                    end
                    char_location = char_location + 1
                end #check directions_from_initial_chars for_end

                return 'not_found'                
            end

            def getCharsLocations(fgrid,row,col,charc)
                v_word_indexes = [];
                for j in 0..(row-1)
                    for k in 0..(col-1)
                        if fgrid[j][k] === charc
                            v_word_indexes.push({"row": j, "col":k})
                        end
                    end
                end
				return v_word_indexes;
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