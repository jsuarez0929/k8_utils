# Usage
USAGE='./ecr_tags [<service_name>] [backend|frontend|middleware] [dev|stage|qa|prod]'

#Gather inputs
module=$1
module_service=$2
env=$3

#Validate input
##env
case $env in
    "stage" | "qa" | "prod")
        env=$env
        ;;
    "dev")
        env=''
        ;;
    *)
        echo "Please specify an environment."
        echo "Usage: $USAGE"
        exit 1
        ;;
esac

#Get details from service_details.json
service_ecr_repo=$(cat $SERVICES_FILE | jq -r ".modules[] | select(.module_name == \"$module\") | .services.$module_service.ecr_repo")

if [ -z $service_ecr_repo ] #Validate service_ecr_repo string (If empty string, previous command failed)
then
    echo "Please check your parameters"
    echo "Usage: $USAGE"
    exit 1
else
    #Get data
    aws ecr list-images --repository-name $service_ecr_repo --region us-east-2 | jq '.imageIds[] | .imageTag' | grep $env | sort
fi
