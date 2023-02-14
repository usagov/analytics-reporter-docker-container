This repository creates a Docker container which runs the 18f analytics reporter [https://github.com/18F/analytics-reporter] which powers analytics.usa.gov.

The base image is the node alpine image from [https://hub.docker.com/_/node]. It copies and runs testscript.sh. The script requires jq to read container variables described below and bash.

To run on cloud.gov....

The script installs the analytics-reporter found in /analytics-reporter. To pull the data variables ANALYTICS_REPORT_IDS, ANALYTICS_REPORT_EMAIL, and ANALYTICS_KEY needed. These are stored in a user provided service instance (here called cupsTest) and are accessible through VCAP_SERVICES [https://docs.cloudfoundry.org/devguide/deploy-apps/environment-variable.html]. The jq tool is used to parse the VCAP_SERVICES. The variables are than exported.

The analytics reporter is called every 900 seconds (equal to 15 minutes).

The output of the analytics reporter is stored on a S3 bucket in cloud.gov. The AWS_REGION,AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_BUCKET and AWS_BUCKET_PATH are also stored in VCAP_SERVICES. The analytics reporter already comes with a pre-configuered lightweight S3 publishing tool which just requires the above variables. The json files are stored on .{} where the json file is one of the 22 following options:

browsers.json
device_model.json
devices.json
ie.json
language.json
last-48-hours.json
os-browsers.json
os.json
realtime.json
screen-size.json
today.json
top-domains-30-days.json
top-domains-7-days.json
top-exit-pages-30-days.json
top-landing-pages-30-days.json
top-pages-30-days.json
top-pages-7-days.json
top-pages-realtime.json
top-traffic-sources-30-days.json
users.json
windows-browsers.json
windows-ie.json
windows.json