#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$((RANDOM%1000+1))

echo "Enter your username:"
read NAME
CHECK_DATABASE=$($PSQL "SELECT name FROM users WHERE name='$NAME'")

# check whether the user exist in database
if [[ -z $CHECK_DATABASE ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(name,games_played) VALUES('$NAME',0)")
  echo "Welcome, $NAME! It looks like this is your first time here."
else
  # if user not in db,then insert
  GAME_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$NAME'")
  echo "Welcome back, $NAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
while [[ $NUMBER != $SECRET_NUMBER ]]
do
  read NUMBER
  ((NUMBER_OF_GUESSES++))
  
  # if not integer
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    # only the valid NUMBER should be count
    ((NUMBER_OF_GUESSES--))

  # if higher
  elif [[ $NUMBER < $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    
  #if lower 
  elif [[ $NUMBER > $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    
  else
    # if guessed secret number
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # update game_played
    ABC=$($PSQL "UPDATE users SET games_played=$GAME_PLAYED + 1 WHERE name='$NAME'")
    
    # if NUMBER_OF_GUESSES < best_game,Update
    if [[ $BEST_GAME -eq 0 || $BEST_GAME > $NUMBER_OF_GUESSES ]]
    then
      BCA=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE name='$NAME'")
    fi
  fi
done