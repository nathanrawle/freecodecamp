#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t -c"

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
elif [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$1
  SELECT_RESULT=$($PSQL "SELECT symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING (atomic_number) INNER JOIN types USING (type_id) WHERE atomic_number = $ATOMIC_NUMBER")
  if [[ -z $SELECT_RESULT ]]
  then
    echo -e "I could not find that element in the database."
  else
    read SYMBOL BAR NAME BAR TYPE BAR MASS BAR MELTING BAR BOILING <<< $SELECT_RESULT
  fi
elif [[ $1 =~ ^[A-Za-z]{1,2}$ ]]
then
  SYMBOL=$1
  SELECT_RESULT=$($PSQL "SELECT atomic_number, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING (atomic_number) INNER JOIN types USING (type_id) WHERE symbol = '$SYMBOL'")
  if [[ -z $SELECT_RESULT ]]
  then
    echo -e "I could not find that element in the database."
  else
    read ATOMIC_NUMBER BAR NAME BAR TYPE BAR MASS BAR MELTING BAR BOILING <<< $SELECT_RESULT
  fi
elif [[ $1 =~ ^[A-Za-z]{3,}$ ]]
then
  NAME=$1
  SELECT_RESULT=$($PSQL "SELECT symbol, atomic_number, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING (atomic_number) INNER JOIN types USING (type_id) WHERE name = '$NAME'")
  if [[ -z $SELECT_RESULT ]]
  then
    echo -e "I could not find that element in the database."
  else
    read SYMBOL BAR ATOMIC_NUMBER BAR TYPE BAR MASS BAR MELTING BAR BOILING <<< $SELECT_RESULT
  fi
else
  echo -e "Input not recognised."
fi

if [[ $TYPE ]]
then
  echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi
