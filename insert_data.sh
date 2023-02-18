#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # Add each unique team to the `teams` table
    TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    if [[ -z $TEAM_ID_W ]]
    then
      ($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
      TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi
    TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    if [[ -z $TEAM_ID_O ]]
    then
      ($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
      TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi

    # Insert each game into the `games` table
    INSERT_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $TEAM_ID_W, $TEAM_ID_O, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_RESULT = "INSERT 0 1" ]]
    then
      echo "Inserted $ROUND game $WINNER vs $OPPONENT"
    else
      echo "FAILED: Insert $ROUND game $WINNER vs $OPPONENT"
    fi
  fi
done
