FROM public.ecr.aws/corelight/software-sensor:1.6.2

RUN apt-get update && apt-get install -y \
    --no-install-recommends git \
    curl \
    wget \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && python3 -m pip install --upgrade --upgrade-strategy only-if-needed pip

RUN python3 -m pip install "zkg" \
    && mkdir /.zkg

RUN pip3 install suricata-update \
    && suricata-update update-sources \
    --suricata-conf=/var/corelight/suricata/.suricata.yaml \
    --suricata=/opt/corelight/bin/suricata -D \
    /etc/corelight/suricata-update \
    && touch /etc/corelight/suricata-update/enable.conf \
    /etc/corelight/suricata-update/disable.conf \
    /etc/corelight/suricata-update/modify.conf \
    /etc/corelight/suricata-update/custom_rules \
    && suricata-update \
    --disable-conf=/etc/corelight/suricata-update/disable.conf \
    --modify-conf=/etc/corelight/suricata-update/modify.conf \
    --enable-conf=/etc/corelight/suricata-update/enable.conf \
    --suricata-conf=/var/corelight/suricata/.suricata.yaml \
    --suricata=/opt/corelight/bin/suricata -D \
    /etc/corelight/suricata-update -o \
    /etc/corelight/rules \
    --local=/etc/corelight/suricata-update/custom_rules --no-test

#filebeat
RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.6.0-linux-x86_64.tar.gz \
    && tar xzvf /filebeat-8.6.0-linux-x86_64.tar.gz \
    && cd filebeat-8.6.0-linux-x86_64 \
    && ./filebeat modules enable zeek 
#    && ./filebeat -c /filebeat-8.6.0-linux-x86_64/filebeat.yml &
# curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.6.0-linux-x86_64.tar.gz --output /opt/filebeat/filebeat-8.6.0-linux-x86_64.tar.gz\
#    tar xzvf  /opt/filebeat/filebeat-8.6.0-linux-x86_64.tar.gz


#curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.5.3-linux-x86_64.tar.gz \
#&& tar xzvf elastic-agent-8.5.3-linux-x86_64.tar.gz 
#    && cd elastic-agent-8.5.3-linux-x86_64 \
#   && ./elastic-agent install --non-interactive 




#Install Zeek packages
RUN yes | zkg install ja3 \
    && yes | zkg install bzar

# ENTRYPOINT ["/opt/corelight/bin/corelight-softsensor"]
# CMD ["start"]
