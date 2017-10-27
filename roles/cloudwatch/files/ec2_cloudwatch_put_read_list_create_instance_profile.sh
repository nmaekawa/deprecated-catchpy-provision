#!/bin/bash

ERROR_CREATING_ROLE=10
ERROR_CREATING_POLICY=11
ERROR_GETTING_POLICY_ARN=12
ERROR_ATTACHING_POLICY_TO_ROLE=13
ERROR_CREATING_INSTANCE_PROFILE=14

AWS_PROFILE=$1
DOCUMENT_PATH=$2
PERMISSION_NAME=$3

PERMISSION_NAME='ec2_cloudwatch_put_read_list'
IAM_PATH="/hx/catchpy/"

# check if instance_profile already exist
INSTANCE_PROFILE=$(aws iam get-instance-profile \
    --instance-profile-name "${PERMISSION_NAME}_instance_profile" \
    --profile "${AWS_PROFILE}")
if [ $? -eq 0 ]; then
    echo "${INSTANCE_PROFILE}" | jq .InstanceProfile.InstanceProfileName
    exit 0
fi


echo "creating managed policy"

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



echo "policy ${POLICY}"
echo "getting arn..."


# get policy arn
POLICY_ARN=$(echo ${POLICY} | jq '.Policy.Arn' | sed 's/"//g')
if [ -z ${POLICY_ARN} ]; then
    exit $ERROR_GETTING_POLICY_ARN
fi



echo "policy arn is ${POLICY_ARN}"
echo "creating role..."



# create role
ROLE=$(aws iam create-role \
    --role-name "${PERMISSION_NAME}_role" \
    --assume-role-policy-document "file://${DOCUMENT_PATH}/${PERMISSION_NAME}_trust_policy.json" \
    --profile "${AWS_PROFILE}")
if [ $? -ne 0 ]; then
    exit $ERROR_CREATING_ROLE
fi



echo "role is ${ROLE}"
echo "attaching policy to role... "



# add managed policy to role
ATTACH_ROLE_POLICY=$(aws iam attach-role-policy \
    --role-name "${PERMISSION_NAME}_role" \
    --policy-arn "${POLICY_ARN}" \
    --profile "${AWS_PROFILE}")
if [ $? -ne 0 ]; then
    exit $ERROR_ATTACHING_POLICY_TO_ROLE
fi



echo "attach-role-policy is ${ATTACH_ROLE_POLICY}"
echo "creating instance profile..."



# create instance profile
INSTANCE_PROFILE=$(aws iam create-instance-profile \
    --instance-profile-name "${PERMISSION_NAME}_instance_profile" \
    --profile "${AWS_PROFILE}")
if [ $? -ne 0 ]; then
    exit $ERROR_CREATING_INSTANCE_PROFILE
fi


echo "instance profile is ${INSTANCE_PROFILE}"
echo "adding role to profile..."



# add role to instance profile
ADD_ROLE_TO_INSTANCE_PROFILE=$(aws iam add-role-to-instance-profile \
    --role-name "${PERMISSION_NAME}_role" \
    --instance-profile-name "${PERMISSION_NAME}_instance_profile" \
    --profile "${AWS_PROFILE}")
if [ $? -ne 0 ]; then
    exit $ERROR_ADDING_ROLE_TO_INSTANCE_PROFILE
fi

echo "${INSTANCE_PROFILE}" | jq .InstanceProfile.InstanceProfileName
