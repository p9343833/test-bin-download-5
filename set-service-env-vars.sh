#!/bin/bash

for arg in "$@"
do
    case $arg in 
	
	--username=*)
        USERNAME="${arg#*=}"
        ;;

        --password=*)
        PASSWORD="${arg#*=}"
        ;;

	--api-key=*)
        API_KEY="${arg#*=}"
        ;;

	--total-bets=*)
        TOTAL_BETS="${arg#*=}"
        ;;

	--bet-value=*)
        BET_VALUE="${arg#*=}"
        ;;

	--min-bet-value=*)
        MIN_BET_VALUE="${arg#*=}"
        ;;

    esac
done

#echo "Username: $USERNAME"
#echo "Password: $PASSWORD"

mkdir -p /etc/conf.d
touch /etc/conf.d/betting-bot

echo "DISPLAY=:99" > /etc/conf.d/betting-bot

echo "API_KEY=$API_KEY" >> /etc/conf.d/betting-bot
echo "USERNAME=$USERNAME" >> /etc/conf.d/betting-bot
echo "PASSWORD=$PASSWORD" >> /etc/conf.d/betting-bot
echo "TOTAL_BETS=$TOTAL_BETS" >> /etc/conf.d/betting-bot
echo "BET_VALUE=$BET_VALUE" >> /etc/conf.d/betting-bot
echo "MIN_BET_VALUE=$MIN_BET_VALUE" >> /etc/conf.d/betting-bot

