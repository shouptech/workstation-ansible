#!/bin/bash

SESSION_NAME="shoup"
AWS_ITEM_NAME="Amazon - YSG"
MFA_ARN="arn:aws:iam::395495440380:mfa/mshoup"
MFA_PROFILE="mfa"

if ! command -v jq &> /dev/null; then
  echo "jq is not installed."
  exit 1
fi

session_var="OP_SESSION_${SESSION_NAME}"
if [ -z ${!session_var} ]; then
  echo "Not signed in to the op cli. Please run the following, then re-execute script:"
  echo 'eval $(op signin '"${SESSION_NAME}"')'
  exit 1
fi

MFA_OTP=$(op get totp "${AWS_ITEM_NAME}")
SESSION_TOKENS=$(aws sts get-session-token --serial-number $MFA_ARN --token-code $MFA_OTP)

if jq '.Credentials' &>/dev/null <<<$SESSION_TOKENS; then
  SESSION_ACCESS_KEY=$(echo $SESSION_TOKENS | jq -r '.Credentials.AccessKeyId')
  SESSION_SECRET_KEY=$(echo $SESSION_TOKENS | jq -r '.Credentials.SecretAccessKey')
  SESSION_TOKEN=$(echo $SESSION_TOKENS | jq -r '.Credentials.SessionToken')

  export AWS_ACCESS_KEY_ID=$SESSION_ACCESS_KEY
  export AWS_SECRET_ACCESS_KEY=$SESSION_SECRET_KEY
  export AWS_SESSION_TOKEN=$SESSION_TOKEN

  aws configure set aws_access_key_id $SESSION_ACCESS_KEY --profile $MFA_PROFILE
  aws configure set aws_secret_access_key $SESSION_SECRET_KEY --profile $MFA_PROFILE
  aws configure set aws_session_token $SESSION_TOKEN --profile $MFA_PROFILE

  echo 'MFA Authorized'
else
  echo 'Could not authorize'
  echo $SESSION_TOKENS
fi
