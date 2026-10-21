#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]; then
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USER_DATA=$($PSQL "SELECT COUNT(*), COALESCE(MIN(number_of_guesses), 0) FROM games WHERE user_id=$USER_ID")
  GAMES_PLAYED=$(echo "$USER_DATA" | cut -d '|' -f 1 | xargs)
  BEST_GAME=$(echo "$USER_DATA" | cut -d '|' -f 2 | xargs)

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

while [[ $GUESS != "$SECRET_NUMBER" ]]; do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

    if (( GUESS > SECRET_NUMBER )); then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi

  read GUESS
done

NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

$PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)"
