#!/bin/sh

# === USAGE ====
USAGE='. getlogs.sh [module] [service]'

# === Output color ===
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ======= Input =======
module=$(cat $SERVICES_FILE | jq -r ".modules[] | select(.module_name==\"$1\") | .module_name")
service=$2

# === Input Validation ==
if [ -z "$module" ]
then
    echo $USAGE
    echo "Please specify a valid module.\n"
    echo "${BLUE}Specify one of the following modules:${NC}"
    cat $SERVICES_FILE | jq -r ".modules[] | .module_name"
    # exit 1
else
    module_log_path="$LOG_FILES_PATH/$module"
    log_path="$LOG_FILES_PATH/$module/$service"

    if [ ! -d "$module_log_path" ]
    then
        mkdir $module_log_path
    fi

    if [ ! -d "$log_path" ]
    then
        mkdir $log_path
    fi

    for value in $(kl get pods -n $module -o=custom-columns=NAME:.metadata.name | grep $service)
    do
        kl logs $value -n $module > $log_path/$value-$(date +"%m-%d-%y--%T").log
        echo Logs have been successfully pulled for: "${GREEN}$value${NC}"
    done

    echo "Creating zip file"
    cd $log_path; zip $module_$service_$(date +"%m-%d-%y_T%T").zip *.log .
    rm -rf $log_path/*.log
fi
