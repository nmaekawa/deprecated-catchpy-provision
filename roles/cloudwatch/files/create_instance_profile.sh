#!/bin/bash
# run this from ansible provisioning host (local

ERROR_CREATING_ROLE=10
ERROR_CREATING_POLICY=11
ERROR_GETTING_POLICY_ARN=12
ERROR_ATTACHING_POLICY_TO_ROLE=13
ERROR_CREATING_INSTANCE_PROFILE=14

AWS_PROFILE=$1
DOCUMENT_PATH=$2
PERMISSION_NAME=${3:-ec2_cloudwatch_put_read_list}
IAM_PATH=${4:-/hx/catchpy/}

echo "permission name is $PERMISSION_NAME"
echo "iab path is $IAM_PATH"

# check if instance_profile already exist
INSTANCE_PROFILE=$(aws iam get-instance-profile \
    --instance-profile-name "${PERMISSION_NAME}_instance_profile" \
    --profile "${AWS_PROFILE}")
if [ $? -eq 0 ]; then
    echo "${INSTANCE_PROFILE}" | jq '.InstanceProfile.InstanceProfileName' | sed 's/"//g'
    exit 0
fi

# create managed policy
POLICY=$(aws iam create-policy \
    --policy-name "${PERMISSION_NAME}_managed_policy" \
    --path "${IAM_PATH}" \
    --description "${PERMISSION_NAME}" \
    --policy-document "file://${DOCUMENT_PATH}/${PERMISSION_NAME}_managed_policy.json" \
    --profile "${AWS_PROFILE}" )
if [ $? -ne 0 ]; then
    exit $ERROR_CREATING_POLICY
fi

# get policy arn
POLICY_ARN=$(echo ${POLICY} | jq '.Policy.Arn' | sed 's/"//g')
if [ -z ${POLICY_ARN} ]; then
    exit $ERROR_GETTING_POLICY_ARN
fi

# create role
ROLE=$(aws iam create-role \
    --role-name "${PERMISSION_NAME}_role" \
    --assume-role-policy-document "file://${DOCUMENT_PATH}/${PERMISSION_NAME}_trust_policy.json" \
    --profile "${AWS_PROFILE}")
if [ $? -ne 0 ]; then
    exit $ERROR_CREATING_ROLE
fi

# add managed policy to role
aws iam attach-role-policy \
    --role-name "${PERMISSION_NAME}_role" \
    --policy-arn "${POLICY_ARN}" \
    --profile "${AWS_PROFILE}"
if [ $? -ne 0 ]; then
    exit $ERROR_ATTACHING_POLICY_TO_ROLE
fi

# create instance profile
INSTANCE_PROFILE=$(aws iam create-instance-profile \
    --instance-profile-name "${PERMISSION_NAME}_instance_profile" \
    --profile "${AWS_PROFILE}")
if [ $? -ne 0 ]; then
    exit $ERROR_CREATING_INSTANCE_PROFILE
fi

# add role to instance profile
ADD_ROLE_TO_INSTANCE_PROFILE=$(aws iam add-role-to-instance-profile \
    --role-name "${PERMISSION_NAME}_role" \
    --instance-profile-name "${PERMISSION_NAME}_instance_profile" \
    --profile "${AWS_PROFILE}")
if [ $? -ne 0 ]; then
    exit $ERROR_ADDING_ROLE_TO_INSTANCE_PROFILE
fi

echo "${INSTANCE_PROFILE}" | jq '.InstanceProfile.InstanceProfileName' | sed 's/"//g'
