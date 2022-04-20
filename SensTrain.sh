sudo passwd root
su root
apt-get install jq

sensory_test_id=YOUR_REDJADE_TEST_ID

REDJADE_CLIENT_ID=YOUR_REDJADE_CLIENT_ID
REDJADE_CLIENT_SECRET=YOUR_REDJADE_CLIENT_SECRET

curl -k --request POST \
"https://app.redjade.net/api/v1/oauth/access_token?client_id=${REDJADE_CLIENT_ID}&client_secret=${REDJADE_CLIENT_SECRET}"

bearer_token=`curl -k --request POST \
"https://app.redjade.net/api/v1/oauth/access_token?client_id=${REDJADE_CLIENT_ID}&client_secret=${REDJADE_CLIENT_SECRET}" | \
jq -r '.response.access_token'
`
echo 'Successfully retrieved bearer token from RedJade'
echo $bearer_token

export sensory_test_id=$sensory_test_id

INPUT=$(curl -k -X POST "https://app.redjade.net/api/v1/sensory_tests/$sensory_test_id/export_raw_data/" -H "authorization: Bearer $bearer_token")
echo $INPUT


SUBSTRING=$(echo $INPUT| cut -d':' -f 6-7)
INPUT2=$SUBSTRING
SUBSTRING2=$(echo $INPUT2| cut -d',' -f 1)
INPUT3=$SUBSTRING2
SUBSTRING3=${INPUT3:1:-1}
echo $SUBSTRING3

sleep 10s

export download_url=$SUBSTRING3
export bearer_token=$bearer_token
curl -k -X GET $download_url -H "authorization: Bearer $bearer_token" --output analysis-export.xlsx
