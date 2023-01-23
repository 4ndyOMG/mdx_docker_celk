#! /bin/bash
if grep -q "8.6.0" /ecs/version > /dev/null; then
    echo -e "ecs version 8.6.0 repo already cloned";
else  echo -e "Cloning/Copying required ecs version 8.6.0 files and installing ecs script requirements";
    git clone https://github.com/elastic/ecs.git
    pip install -r /ecs/scripts/requirements.txt
fi;

if grep -q "ecs-corelight" /ecs/generated/elasticsearch/composable/template.json > /dev/null; then
    echo "ecs artifacts already created";
else echo "Creating ecs artifacts"
    cd /ecs/
    git checkout v8.6.0
    python3 ./scripts/generator.py --subset /opt/corelight/subset-corelight.yml;
fi;

auth="elastic:${ELASTIC_PASSWORD}"
if curl -s --user "$auth" -XGET "https://localhost:9200/_index_template/ecs_corelight" --insecure --header "Content-Type: application/json" | grep -qv "error"; then
    echo "corelight ecs template installed"
else echo "Installing ecs templates"
    cd /ecs/
    for file in `ls ./generated/elasticsearch/composable/component/*.json`
    do
    fieldset=`echo $file | cut -d/ -f6 | cut -d. -f1 | tr A-Z a-z`
    echo "filedset is: ecs_8.6.0-$fieldset"
    component_name="ecs_8.6.0_$fieldset"
    api="_component_template/$component_name"
    echo "Template name is: $component_name component_name"

    echo "$file => $api"
    curl --user "${auth}" -XPUT "https://localhost:9200/$api" --insecure --header "Content-Type: application/json" -d @"$file"
    echo " "
    done
    echo "pwd is: $(pwd) before sed command"
    echo "dir is $(ls -la)"
    sed -i 's/try-ecs/ecs-corelight/' ./generated/elasticsearch/composable/template.json

    api2="_index_template/ecs_corelight"
    file2="./generated/elasticsearch/composable/template.json"

    echo $api2
    curl -q --user "$auth" -XPUT "https://localhost:9200/$api2" --insecure --header "Content-Type: application/json" -d @"$file2"
fi;