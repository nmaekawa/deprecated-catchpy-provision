#!/bin/bash

. {{ hx_rootdir }}/bin/custom_metrics_shared.sh

instance_id="$1"
metric_name="WebserviceResponseTime"

make_jwt='{{ service_venv_dir }}/bin/python {{ service_venv_dir }}/bin/make_jwt.py
           {{ cloudwatch_api_key }}  {{ cloudwatch_secret_key }}
           {{ cloudwatch_user }}
         '
catch_jwt=$(${make_jwt})

check_app='resp_time=$(curl -w "%{time_total}"
            -H "Authorization: token ${catch_jwt}"
            {{ (env == "prod") | ternary("https", "http") }}://{{ webserver_dns }}/is_alive
            -o {{ hx_rootdir }}/conf/is_alive_response.json -s
        )'
echo $check_app

# TODO: the idea is to call this:
response_time=$(${check_app})
# check that payload is ok from is_alive response; needs to install jq
# or assume that responding means ok
is_alive=$(cat {{ hx_rootdir }}/conf/is_alive_response.json | jq .payload[0] == 'ok')
# then put-metric-data ${response_time} to cloudwatch
if [ ${is_alive} == 'true' ]; then
  /usr/local/bin/aws cloudwatch put-metric-data \
      --region="$region" \
      --namespace="$namespace" \
      --dimensions="InstanceId=$instance_id" \
      --metric-name="$metric_name" \
      --value="$response_time" \
      --unit Seconds
fi

