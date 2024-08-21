#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to my Salon how can I help you?"
  SERVICES_OFFERED=$($PSQL "SELECT * FROM services")
  echo "$SERVICES_OFFERED" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Choose a number for the service present on the list"
  else
    SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
    then
      MAIN_MENU "Choose a number for the service present on the list"
    else
     SERVICE_ID_SELECTED_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      BOOKING $SERVICE_ID_SELECTED_NAME $SERVICE_ID_SELECTED
    fi
  fi
}

BOOKING() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWe don't have your name in the system. What's your name?"
    read CUSTOMER_NAME
    INSERT_NEW_CLIENT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  echo -e "\nWhat time would you like your $1, $CUSTOMER_NAME"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$2,'$SERVICE_TIME')")
  echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME."
}


MAIN_MENU