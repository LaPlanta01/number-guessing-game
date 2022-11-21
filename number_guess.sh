#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(($RANDOM%1000+1))

USERNAME_F (){
	echo -e "\nEnter your username:" 
	read USERNAME

	if [[ ${#USERNAME} -lt 22 ]]
	then
		echo -e "\nUsername has to be at least of 22 characters"
		USERNAME_F
	fi

	LOOK_USER=$($PSQL "SELECT username FROM users")

	for i in $LOOK_USER
	do
		if [[ $i == $USERNAME ]]
		then
			COINCIDENCE=1
			READ_USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")
			echo $READ_USER | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
		do
			echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
		done
		fi
	done
	if [[ $COINCIDENCE != 1 ]]
	then
		INSERT_NEW_USER=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, 0)")			
		echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
	fi

			
}

GUESSING_NUMBER (){

	echo -e "\nGuess the secret number between 1 and 1000: " 
	read INPUT_NUMBER

	while [[ $INPUT_NUMBER -ne $NUMBER ]]
	do
		if [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
		then 
			echo -e "\nThat is not an integer, guess again: " 
			read INPUT_NUMBER
		elif [[ $INPUT_NUMBER > $NUMBER ]]
		then
			echo -e "\nIt's lower than that, guess again: " 
			read INPUT_NUMBER
		elif [[ $INPUT_NUMBER < $NUMBER ]]
		then 
			echo -e "\nIt's higher than that, guess again: " 
			read INPUT_NUMBER

		fi

		NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))


	done
	
	echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"

	return $NUMBER_OF_GUESSES

}

INSERT_DATA () {
	GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
	NEW_GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
	INSERT_NEW_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED WHERE username = '$USERNAME'")

	READ_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'") 
	if [[ $NUMBER_OF_GUESSES < $READ_BEST_GAME || $READ_BEST_GAME == 0 ]]
	then
		INSERT_NUMBER_OF_GUESSES=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
	fi

}
USERNAME_F
GUESSING_NUMBER
INSERT_DATA
