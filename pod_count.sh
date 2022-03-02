#!/bin/sh

# === USAGE ====
USAGE='. pod_count.sh'


for value in $(kl get nodes -o=custom-columns=NAME:.metadata.name | grep ip)
do
    count=$(kl get pods --all-namespaces -o wide | grep "$value" | wc -l)
    echo $value $count
done
