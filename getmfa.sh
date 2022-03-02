#!/bin/sh

# Output color ===
GREEN='\033[0;32m'
NC='\033[0m'
# =================

# Remove AWS credentials from the environment
function unset_credentials {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_DEFAULT_PROFILE
    unset AWS_PROFILE
}

if [ $1 = "unset" ]
then
    unset_credentials
elif [ $1 = "set" ]
then
    unset_credentials

    env=$2
    token=$3
    export AWS_PROFILE=$env


    case $env in
        "dev")
            user_account='arn:aws:iam::<aws_acct_number>:mfa/<usr_name>'
            ;;

        "prod")
            user_account='arn:aws:iam::<aws_acct_number>:mfa/<usr_name>'
            ;;

        "test")
            user_account='arn:aws:iam::<aws_acct_number>:mfa/<usr_name>'
            ;;

        *)
            echo "Please specify an environment."
            echo "Usage: ./getmfa.sh [set|unset] [env] [mfa_token]"
            exit 1
            ;;
    esac

    json_response=`aws sts get-session-token --serial-number $user_account --token-code $token`

    if [ $? -eq 0 ] # Check status code of previous command (aws cli response)
    then
        secret_access_key=`jq -nr "${json_response}|.Credentials.SecretAccessKey"`
        session_token=`jq -nr "${json_response}|.Credentials.SessionToken"`
        access_key_id=`jq -nr "${json_response}|.Credentials.AccessKeyId"`

        # Set AWS credentials as env vars for current sh session
        export AWS_ACCESS_KEY_ID=$access_key_id
        export AWS_SECRET_ACCESS_KEY=$secret_access_key
        export AWS_SESSION_TOKEN=$session_token

        echo "${GREEN}AWS_ACCESS_KEY_ID${NC}:    "$AWS_ACCESS_KEY_ID
        echo "${GREEN}AWS_SECRET_ACCESS_ID${NC}: "$AWS_SECRET_ACCESS_KEY
        echo "${GREEN}AWS_SESSION_TOKEN${NC}:    "$AWS_SESSION_TOKEN
    fi

else
    echo "Please specify a set or unset command"
    echo "Usage: ./getmfa.sh [set|unset] [env] [mfa_token]"
    exit 1
fi
