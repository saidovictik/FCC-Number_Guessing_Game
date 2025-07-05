#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Fetch user_id and username if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  # New user
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user into the database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  # Get the newly generated user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
else
  # Returning user
  # Fetch game statistics
  GAME_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_guess) FROM games WHERE user_id = $USER_ID")

  echo -e "Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Game logic starts here
RANDOM_NUM=$(( $RANDOM % 1000 + 1 ))
GUESS_COUNT=0 # Renamed GUESS to GUESS_COUNT for clarity

echo -e "\nGuess the secret number between 1 and 1000:"

while read INPT_NUM
do
  GUESS_COUNT=$(( GUESS_COUNT + 1 )) # Increment guess count inside the loop

  if [[ ! $INPT_NUM =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
  elif [[ $INPT_NUM -eq $RANDOM_NUM ]]
  then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
    # Insert game result into the database
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_guess) VALUES($USER_ID, $GUESS_COUNT)")
    break;
  elif [[ $INPT_NUM -lt $RANDOM_NUM ]]
  then
    echo -e "It's higher than that, guess again:" # Corrected prompt
  elif [[ $INPT_NUM -gt $RANDOM_NUM ]]
  then
    echo -e "It's lower than that, guess again:" # Corrected prompt
  fi
done
