This repository creates a Docker container which runs the 18f [analytics-reporter](https://github.com/18F/analytics-reporter) which powers analytics.usa.gov.

The base image is the [node alpine image](https://hub.docker.com/_/node). It copies and runs testscript.sh. The script requires [jq](https://stedolan.github.io/jq/manual/) to read container variables described below and bash.

The script installs the [analytics-reporter](https://github.com/18F/analytics-reporter) found in /analytics-reporter. To pull the data variables ANALYTICS_REPORT_IDS, ANALYTICS_REPORT_EMAIL, and ANALYTICS_KEY needed. These are stored in a user provided service instance (here called cupsTest) and are accessible through [VCAP_SERVICES](https://docs.cloudfoundry.org/devguide/deploy-apps/environment-variable.html). The jq tool is used to parse the VCAP_SERVICES. The variables are than exported.

### User Provided Services (UPS):
  Cloud front documentation states:
  > “Note: Do not use user-provided environment variables for security sensitive information such as credentials as they might unintentionally show up in cf CLI output and Cloud Controller logs. Use user-provided service instances instead. The system-provided environment variable VCAP_SERVICES is properly redacted for user roles such as Space Supporter and in Cloud Controller log files.”

Eight environment variables (ANALYTICS_REPORT_IDS, ANALYTICS_REPORT_EMAIL, ANALYTICS_KEY, AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_BUCKET, AWS_BUCKET_PATH) must be saved and provided as a UPS. The below instructions were found here: [IBM Link for CUPS](https://www.ibm.com/docs/en/cloud-private/3.2.x?topic=ubicfee-working-user-provided-services-in-cloud-foundry-enterprise-environment).

First Time:
  - cf cups cupsTest -p {vcap_keys}.json
  - cf bind-service {cf-app-name} cupsTest
  - cf restage {cf-app-name}

Subsequent/Updates:
  - cf uups cupsTest -p {vcap_keys}.json
  - docker buildx use default
  - docker buildx build -t {docker-repo}/{image}  --platform linux/amd64 .
  - docker push {docker-repo}/{image}
  - CF_DOCKER_PASSWORD={docker-password} cf push {cf-app-name}

The analytics reporter is called every 900 seconds (equal to 15 minutes).

### S3 on Cloud.Gov
The output of the analytics reporter is stored on a S3 bucket in cloud.gov. The AWS_REGION,AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_BUCKET and AWS_BUCKET_PATH are also stored in VCAP_SERVICES. The analytics reporter already comes with a pre-configuered lightweight S3 publishing tool which just requires the above variables. The json files are stored at https://s3-{AWS_REGION}.amazonaws.com/{aws_bucket}/usagov-analytics/{json-file} where the {json-file} is one of the 23 following options:
|       |        |
| :----:       |    :----:   |
| browsers.json | top-domains-30-days.json |
| device_model.json  | top-domains-7-days.json |
| devices.json | top-exit-pages-30-days.json |
| ie.json  |  top-landing-pages-30-days.json |
| language.json |  top-pages-30-days.json |
| last-48-hours.json  | top-pages-7-days.json |
| os-browsers.json |  top-pages-realtime.json |
| os.json  | top-traffic-sources-30-days.json |
| realtime.json | users.json |
| screen-size.json  | windows-browsers.json |
| today.json | windows-ie.json    |
|  | windows.json |


### Variables, Keys & Credentials you will need
| Docker | Cloud.gov | Google Analytics | AWS |
| --- | --- | --- | --- |
| docker-repo | cf-app-name | ANALYTICS_REPORT_EMAIL | AWS_ACCESS_KEY_ID |
| image | cf-user | ANALYTICS_KEY| AWS_SECRET_ACCESS_KEY |
| json-file | s3user-provided-service | AWS_REGION | AWS_BUCKET |
| --- | --- | --- | AWS_BUCKET_PATH |


## Create docker container for local to write to terminal
1. cd /analytics-reporter-docker-container
2. In testscript.sh change last line to:
    - ./bin/analytics --only users
3. docker buildx use default
4. docker build -t nr-local .
5. docker run nr-local
6. If env.txt file present:
    - docker run --env-file env.txt nr-local

## Create docker container for local to write to S3
1. Make S3 bucket
    - cf create-service s3 basic-public-sandbox {s3user-provided-service}
    - cf bind-service {cf-app-name} {s3user-provided-service}
    - cf restage {cf-app-name}
    - cf create-service-key {s3user-provided-service} {cf-user}
    - cf service-key {s3user-provided-service} {cf-user}
    - Export aws credentials (region, access key, secret access key and bucket)in testscript.sh
      - This will later be moved to VCAP_SERVICES
2. cd /analytics-reporter-docker-container
3. In testscript.sh change last line to:
    - ./bin/analytics --publish --only users
4. docker buildx use default
5. docker build -t nr-local .
6. docker run nr-local
7. If env.txt file present:
   - docker run --env-file env.txt nr-local
8. To see output:
   - https://s3-{AWS_REGION}.amazonaws.com/{aws_bucket}/usagov-analytics/{json-file}

## Create docker container for cloud.gov to write to terminal
1. cd /analytics-reporter-docker-container
2. In testscript.sh change last line to: ./bin/analytics --only users
3. docker buildx use default
4. docker buildx build -t {docker-repo}/{image}  --platform linux/amd64 .
5. docker push {docker-repo}/{image}
6. make repo private on hub.docker
7. Push to cloud.gov:
    - from public repo:
      - cf push {image} --docker-image {docker-repo}/{image}
    - from private repo:
      - CF_DOCKER_PASSWORD={docker-password} cf push {image} --docker-image {docker-repo}/{image}   --docker-username {docker-repo}

## Create docker container for cloud.gov to write to S3
1. cd /analytics-reporter-docker-container
2. In testscript.sh change last line to: ./bin/analytics --only users
3. docker buildx use default
4. docker buildx build -t {docker-repo}/{image}  --platform linux/amd64 .
5. docker push {docker-repo}/{image}
6. make repo private on hub.docker
7. Push to cloud.gov:
    - from public repo:
      - cf push {image} --docker-image {docker-repo}/{image}
    - from private repo:
      - CF_DOCKER_PASSWORD={docker-password} cf push {image} --docker-image {docker-repo}/{image}   --docker-username {docker-repo}
    - if docker in manifest.yml:
      - CF_DOCKER_PASSWORD={docker-password} cf push {cf-app-name}
8. Make S3 bucket
    - cf create-service s3 basic-public-sandbox {s3user-provided-service}
    - cf bind-service {cf-app-name} {s3user-provided-service}
    - cf restage {cf-app-name}
    - cf create-service-key {s3user-provided-service} {cf-user}
    - cf service-key {s3user-provided-service} {cf-user}
    - Export aws credentials (region, access key, secret access key and bucket)in testscript.sh
9. In testscript.sh change last line to: ./bin/analytics --publish
10. repeat steps 4, 5, & 7 again
11. Access via:
    - https://s3-{AWS_REGION}.amazonaws.com/{AWS_BUCKET}/usagov-analytics/{json-file}

## Create docker container for cloud.gov to write to S3 every 15 min














