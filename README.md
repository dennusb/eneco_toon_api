Eneco's Toon API
==============

I'm publishing scripts and information here about Eneco's Toon API!
For the scripts you need to install 'JQ' on your system. Get it here : http://stedolan.github.io/jq/download/
Then move the jq file to /usr/sbin and do a 'chmod +x jq' on the file.

Usage of the retrieve script :
scriptname.sh <emailadres> <password>
The script will retrieve address data and temperature, gas & power consumption. Please be carefull not to run it to often, the API then stops returning all of the data.
Once per 2 minutes is good.