#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"

MAIN() {
  SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

  echo "Enter your username:"
  read USERNAME

  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")

  if [[ -z $PLAYER_ID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO players (username) VALUES 
    ('$USERNAME')")
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")
  else
    read TIMES_PLAYED BAR BEST_SCORE <<< $($PSQL "SELECT COUNT(*), MIN(score) FROM games WHERE player_id = $PLAYER_ID GROUP BY player_id")
    echo "Welcome back, $USERNAME! You have played $TIMES_PLAYED games, and your best game took $BEST_SCORE guesses."
  fi

  echo "Guess the secret number between 1 and 1000:"
  read USER_GUESS
  REPEAT_UNTIL_INTEGER
  GUESS_COUNT=1

  while [[ $USER_GUESS != $SECRET_NUMBER ]]
  do
    if [[ $USER_GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi

    read USER_GUESS
    REPEAT_UNTIL_INTEGER
    ((GUESS_COUNT+=1))
  done

  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (player_id,secret_number,score) VALUES ($PLAYER_ID,$SECRET_NUMBER,$GUESS_COUNT)")

  echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
}

REPEAT_UNTIL_INTEGER () {
  while [[ ! $USER_GUESS =~ ^[0-9]{1,4}$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_GUESS
  done
}

MAIN
