#!/bin/sh
# Client API call.
#
### BEGIN INFO
# Provides:          retrieve.sh
# Call:              retrieve.sh <email> <password>
# Description:       API call to Eneco Toon API
# Version:           1.0
### END INFO

echo "$(date) Start retrieving information for $1"


if [ -z $1 ]; then
	echo "$(date) No email address found. Exiting."
    exit 0
fi

	USERLOGIN="$1"
	USERPASSD="$2"

	curl -s 'https://toonopafstand.eneco.nl/toonMobileBackendWeb/client/login' --data "username=$USERLOGIN&password=$USERPASSD" -s > .dump
	RESPONSE=`grep "504 Gateway Time-out" .dump | wc -l`

	if [ $RESPONSE -ne "0" ]; then
	    echo "$(date) Gateway problems at Eneco. We will stop retrieving information for now."
	    exit 0
	fi
	street=`cat .dump | jq '.agreements[0].street' | tr -d '"'`
	housenumber=`cat .dump | jq '.agreements[0].houseNumber' | tr -d '"'`
	postalcode=`cat .dump | jq '.agreements[0].postalCode' | tr -d '"'`
	cat .dump | jq '.agreements[0].city' | tr -d '"' > .city
	sed "s/'//g" .city > .cityok
	city=`cat .cityok`
	echo "Retrieving information for : \n $street $housenumber \n $postalcode $city\n"


CLIENT_ID=`cat .dump | jq '.clientId' | tr -d '"'`
CLIENT_CHK=`cat .dump | jq '.clientIdChecksum' | tr -d '"'`
AGREE_ID=`cat .dump | jq '.agreements[0].agreementId' | tr -d '"'`
AGREE_CHK=`cat .dump | jq '.agreements[0].agreementIdChecksum' | tr -d '"'`

START=`curl 'https://toonopafstand.eneco.nl/toonMobileBackendWeb/client/auth/start?clientId='$CLIENT_ID'&clientIdChecksum='$CLIENT_CHK'&agreementId='$AGREE_ID'&agreementIdChecksum='$AGREE_CHK'&random=bdbeb5d9-f15e-6f42-8256-c65a61ade671&_=1384550425823' -s | jq '.success'`
curl -s 'https://toonopafstand.eneco.nl/toonMobileBackendWeb/client/auth/retrieveToonState?clientId='$CLIENT_ID'&clientIdChecksum='$CLIENT_CHK'&random=a9e5d375-31a6-3bed-c05a-e713c4503a2c&_=1384550425849' > .state
OUTPUT=`grep thermostat .state | wc -l`
if [ $OUTPUT -eq "0" ]
then
	echo "$(date) We are missing information in the latest response. Please try again!"
	cat .state
	echo "\n"
else
	jq '.thermostatInfo.currentTemp' .state > .currenttemp
	jq '.powerUsage.value' .state > .currentpw
	jq '.gasUsage.value' .state > .currentgas

	current_temp=`cat .currenttemp`
	current_pwusage=`cat .currentpw`
	current_gas=`cat .currentgas`

if [ $current_temp -ne 0 ] && [ $current_pwusage -ne 0 ]; then
	echo "Information retrieved!  \n Current Temperature : $current_temp\n Current Power Consumption : $current_pwusage\n Current Gas Consumption : $current_gas"
	
else
	echo "$(date) ERROR [User:$USERID] : Missing critical data(PW : $current_pwusage) (Temp : $current_temp)."
	echo "Missing data.We can't continue!"
fi
fi

