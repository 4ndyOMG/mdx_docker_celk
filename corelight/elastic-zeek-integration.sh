#! /bin/bash
echo "Waiting for Elasticsearch availability";
until curl -s --cacert /usr/share/corelight/config/certs/ca/ca.crt https://localhost:${ES_PORT}/ | grep -q "missing authentication credentials"; do sleep 30; done;
echo "Waiting for Kibana availability";
until curl -s http://localhost:${KIBANA_PORT}/api/status | grep -q "Unauthorized"; do sleep 30; done;
echo "Installing zeek integration";
auth="elastic:${ELASTIC_PASSWORD}"
api2="api/fleet/package_policies"
integration="/opt/elastic/elastic-zeek-integration-api.json"
echo $api2
url="http://localhost:${KIBANA_PORT}/$api2"
echo $url
curl -q --user "$auth" -XPOST "$url" --header "Content-Type: application/json" --header "kbn-xsrf: reporting" -d @"$integration"
echo "done"