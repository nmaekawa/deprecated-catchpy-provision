#!/bin/bash

. {{ cloudwatch_user_home }}/bin/custom_metrics_shared.sh

metric_name="WebserviceResponseTime"

catch_jwt=$({{ service_venv_dir }}/bin/python {{ cloudwatch_user_home }}/bin/make_jwt.py {{ cloudwatch_api_key }} {{ cloudwatch_secret_key }} {{ cloudwatch_user }})

response_time=$(curl -w "%{time_total}" \
    --silent \
    -H "Authorization: token ${catch_jwt}" \
    {{ (enable_ssl == "true") | ternary("https", "http") }}://{{ webserver_dns }}/is_alive \
    -o {{ cloudwatch_user_home }}/tmp/cloudwatch/is_alive_response.json)

# check that payload is ok from is_alive response; needs to install jq
# or assume that responding means ok
is_alive=$(cat {{ cloudwatch_user_home }}/tmp/cloudwatch/is_alive_response.json | jq '.payload[0] == "ok"')
# then put-metric-data ${response_time} to cloudwatch
if [ ${is_alive} == 'true' ]; then
  /usr/bin/aws cloudwatch put-metric-data \
      --region="$region" \
      --namespace="$namespace" \
      --dimensions="InstanceId=$instance_id" \
      --metric-name="$metric_name" \
      --value="$response_time" \
      --unit Seconds
fi

# remove output file
rm {{ cloudwatch_user_home }}/tmp/cloudwatch/is_alive_response.json

