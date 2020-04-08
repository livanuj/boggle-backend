TECHNOLOGIES:
1. Ruby version => '2.6.5'/ Rails '6.0.2' (https://rubyinstaller.org/ | https://www.ruby-lang.org/en/downloads/)
2. MYSQL server (used mysql 8 with wamp) (http://www.wampserver.com/en/#download-wrapper | https://dev.mysql.com/doc/mysql-installation-excerpt/5.7/en/)

SETUP:
1. Open command line/terminal, go to project folder and use commands

    - To install bundler for installing other gems
        - gem install bundler
    - To install required packages
        - bundle install
    
    - To install rails
        - gem install rails
        
    - To configure the database config, go to config/database.yml and change required configs
        -  username: your_db_username
           password: your_db_password
           host: your_db_host
    
    - Then to create database 
        - rake db:create
    - To create required tables (`word_matrices` and `matrix_valid_words`)
        - rails db:migrate

    - To run the project with port 3002
        - rails server -p 3002

NOTE:
1. For test purpose, initially it displays only 2 puzzles  ['SYRMPAASKRILFEAI','ONEBITINSSCGANTD']
    BUT, scripts are already there which allows to create random new puzzles and also returns new or existing puzzles randomly upon each request
2. No any past test data initially, as running projects and playing 2/3 times will shows the test statistics.
3. Search words, which are valid in puzzle and not overlapping
4. Then if validates, checks the found word in dictionary API (used Yandex dictionary api)
    - for some past tense,and plural words were not found in Yandex
5. Has User current game statistics : total score, total words, longest word.
6. Has past puzzle statistics: high scores, longest word, most words, played times.


API LINK INFO:

1. Getting random puzzle matrix (POST)
	
    - http://localhost:3002/api/v1/word_matrices/getMatrixData
	
	post params
	{
	"size":4
	}

2. Validating word in matrix with yandex dictionary (POST)

	- http://localhost:3002/api/v1/boggle/findValidWordsFromMatrixData
		
	post params
	{
	"matrix_value": "ABCDEFGHIJKLMNOP",
	"matrix_id": 1,
	"puzzle_instance": "crafbae4nz3isoc",
	"size": 4,
	"word": "ABC"
	}

3.  To get the past puzzle statistics

    - http://localhost:3002/api/v1/matrix_valid_words/getPuzzleStats (POST)

	post params
	{
	"word_matrix_id":1
	}