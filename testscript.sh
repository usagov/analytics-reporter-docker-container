#!/bin/bash
echo starting container testscript.sh
cd analytics-reporter

npm install -g analytics-reporter
npm install minimist

AWS_REGION=$(jq -r '.["user-provided"]| .[].credentials | .["AWS_REGION"]' <<< "$VCAP_SERVICES")

AWS_ACCESS_KEY_ID=$(jq -r '.["user-provided"]| .[].credentials | .["AWS_ACCESS_KEY_ID"]' <<< "$VCAP_SERVICES")

AWS_SECRET_ACCESS_KEY=$(jq -r '.["user-provided"]| .[].credentials | .["AWS_SECRET_ACCESS_KEY"]' <<< "$VCAP_SERVICES")

AWS_BUCKET=$(jq -r '.["user-provided"]| .[].credentials | .["AWS_BUCKET"]' <<< "$VCAP_SERVICES")
AWS_BUCKET_PATH=$(jq -r '.["user-provided"]| .[].credentials | .["AWS_BUCKET_PATH"]' <<< "$VCAP_SERVICES")

ANALYTICS_REPORT_IDS=$(jq -r '.["user-provided"]| .[].credentials | .["ANALYTICS_REPORT_IDS"]' <<< "$VCAP_SERVICES")

ANALYTICS_REPORT_EMAIL=$(jq -r '.["user-provided"]| .[].credentials | .["ANALYTICS_REPORT_EMAIL"]' <<< "$VCAP_SERVICES")

ANALYTICS_KEY=$(jq -r '.["user-provided"]| .[].credentials | .["ANALYTICS_KEY"]' <<< "$VCAP_SERVICES")

export ANALYTICS_KEY=$ANALYTICS_KEY
export AWS_REGION=$AWS_REGION
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_BUCKET=$AWS_BUCKET
export AWS_BUCKET_PATH=$AWS_BUCKET_PATH
export ANALYTICS_REPORT_IDS=$ANALYTICS_REPORT_IDS
export ANALYTICS_REPORT_EMAIL=$ANALYTICS_REPORT_EMAIL

while true;
do
  ./bin/analytics --publish;
  # ping every 900- 15 min;
  sleep 900;
done;


echo ending container testscript.sh
