#!/bin/bash

. {{ hx_rootdir }}/bin/custom_metrics_shared.sh

# TODO: missing consumer/secret key-pair for monitoring
make_jwt='{{ service_venv_dir }}/bin/python {{ service_venv_dir }}/bin/make_jwt.py'

check_app='resp_time=$(curl -w "%{time_total}"
            -H "Authorization: token $(make_jwt)"
            {{ (env == "prod") | ternary("https", "http") }}://{{ webserver_dns }}/is_alive
            -o {{ hx_rootdir }}/conf/is_alive_response.json -s
        )'
echo $check_app

# TODO: the idea is to call this:
# response_time=$(${check_app})
# check that payload is ok from is_alive response; needs to install jq
# or assume that responding means ok
# cat {{ hx_rootdir }}/conf/is_alive_response.json | jq .payload[0] == 'ok'
# then put-metric-data ${response_time} to cloudwatch

