#!/bin/bash
echo "Welcome to celk containerised install."
echo "To do list contains: User controlled memory limit for containers. Variable mem_limit is set in the .env file. 
Configure filebeat user for corelight integration with Elasticsearch. 
Use docker secrets for passwords. 
Add cert.ca to remove --insecure options in logstash and corelight."

echo "Do you have git and docker installed? "
soft_list=("git" "docker")
for name in ${soft_list[@]}; do
    dpkg -s $name &> /dev/null  
    if [ $? -ne 0 ]
        then
            echo "not installed, installing $name"  
            sudo apt update
            sudo apt install $name
        else
            echo    "$name installed"
    fi
done

echo "ELK memory limit is set at 5.5Gb each. Can your machine handle that? If not quit at next question."

echo "Setting docker as a service."
sudo systemctl enable docker
echo "Cloning mdx_docker_elk repo"
git clone https://github.com/4ndyOMG/mdx_docker_celk.git &&
cd ./mdx_docker_celk

read -sp 'Enter Corelight License key: ' licenseKey

echo $licenseKey > ./corelight/corelight-license.txt

echo "Which stack would you like to run?"
select services in "Corelight_into_ELK" "ELK"
    do stack=$services
    break
done

if [ $stack == "Corelight_into_ELK" ]; 
    then echo "Corelight-softsensor into ELK has fially been selected"
    cdir=$(pwd)
    echo "Please, select a network interface:"
    cd /sys/class/net && 
    select foo in  *
        do int=$foo 
        break
    done
    echo "Interface $int selected"
    cd $cdir

    conf_int=$(grep -P '(?!.*eth0~4)Corelight::sniff' ./corelight/corelight-softsensor.conf | cut -d " " -f 2)
    echo "Current inr in conf file is: $conf_int"
    sed -i "s/Corelight::sniff $conf_int/Corelight::sniff $int/" ./corelight/corelight-softsensor.conf &&
    echo "Running corelight softsensor with logs into elasticsearch"
    docker compose up -d && 
#    docker container exec corelight-softsensor /bin/bash -c '/filebeat-8.6.0-linux-x86_64/filebeat -c /filebeat-8.6.0-linux-x86_64/filebeat.yml modules enable zeek' &&
#    docker container exec corelight-softsensor /bin/bash -c 'mv /opt/zeek.yml /filebeat-8.6.0-linux-x86_64/modules.d/zeek.yml' &&
    docker container exec corelight-softsensor /bin/bash -c 'chmod go-w /filebeat-8.6.0-linux-x86_64/filebeat.yml' &&
    docker container exec corelight-softsensor /bin/bash -c 'chown root:root /filebeat-8.6.0-linux-x86_64/filebeat.yml' &&
    docker container exec -d corelight-softsensor /bin/bash -c '/filebeat-8.6.0-linux-x86_64/filebeat -c /filebeat-8.6.0-linux-x86_64/filebeat.yml'

    elif [ $stack == "ELK" ]; then 
    echo "ELK selected"

    else echo "Running ELK stack"
    docker compose up setup es01 es02 es03 kibana logstash -d 
fi

echo "To shutdown all container whilst persisting data run: docker compose down"
echo "To shutdown all containers and delete data run: docker compose down -v"
echo "To shutdown corelight alone run docker stop corelight-softsensor"
echo "Script complete"