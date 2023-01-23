FROM ubuntu:latest

RUN apt update && apt install -y \
    git \
    curl \
    python3-pip 

#ENTRYPOINT ["/opt/elastic-agent/elastic-zeek-integration.sh"]
ENTRYPOINT ["/opt/corelight/ecs_template.sh"]
