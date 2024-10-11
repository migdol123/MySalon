#!/bin/bash

# Function to display services
display_services() {
  echo "Here are the available services:"
  
  # Get the list of services, then format it correctly using sed
  psql -X --username=postgres --dbname=salon --tuples-only -c "SELECT service_id, name FROM services" | sed '/^ *$/d; s/|//g; s/^ *//; s/ *$//' | while read -r SERVICE_ID NAME
  do
    # Check if both SERVICE_ID and NAME are not empty
    if [[ -n $SERVICE_ID && -n $NAME ]]; then
      echo "$SERVICE_ID) $NAME"
    fi
  done
}

# Function to prompt user to select a service and validate input
get_service() {
  while true; do
    display_services
    echo "Please enter the service number you would like:"
    read SERVICE_ID_SELECTED

    # Check if the selected service ID exists in the services table
    SERVICE_NAME=$(psql -X --username=postgres --dbname=salon --tuples-only -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # If the service exists, break the loop; otherwise, show the list again
    if [[ -n $SERVICE_NAME ]]
    then
      break
    else
      echo "Invalid service number. Please select a valid service."
    fi
  done
}

# Function to prompt for customer phone number
get_customer() {
  echo "Please enter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$(psql -X --username=postgres --dbname=salon --tuples-only -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo "It looks like you're a new customer. Please enter your name:"
    read CUSTOMER_NAME
    psql -X --username=postgres --dbname=salon --tuples-only -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
  fi
}

# Function to prompt for appointment time
get_time() {
  echo "Please enter a time for your appointment:"
  read SERVICE_TIME
}

# Main program
get_service
get_customer
get_time

# Insert the appointment into the appointments table
CUSTOMER_ID=$(psql -X --username=postgres --dbname=salon --tuples-only -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
psql -X --username=postgres --dbname=salon --tuples-only -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Confirmation message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
