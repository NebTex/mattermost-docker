FROM mattermost/mattermost-prod-app:latest

RUN adduser --disabled-password --gecos "" mattermost

## install gosu
ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget unzip python-pip && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true 

##install dumb-init
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
RUN dpkg -i dumb-init_*.deb

##install consul-template
RUN wget https://releases.hashicorp.com/consul-template/0.18.0-rc2/consul-template_0.18.0-rc2_linux_amd64.zip
RUN unzip consul-template_0.18.0-rc2_linux_amd64.zip
RUN cp consul-template /bin/consul-template
RUN chmod +x /bin/consul-template

##install jq
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN cp jq-linux64 /bin/jq
RUN chmod +x /bin/jq

##install supervisor
RUN pip install supervisor

ADD entrypoint.sh /bin/entrypoint.sh
RUN chmod +x  /bin/entrypoint.sh

ADD mattermost.sh /bin/mattermost.sh
RUN chmod +x  /bin/mattermost.sh

ADD run_consul_template.sh /bin/run_consul_template.sh
RUN chmod +x  /bin/run_consul_template.sh

ADD templates /templates
RUN mv /templates/supervisord.conf /usr/local/etc/supervisord.conf

ENTRYPOINT ["/bin/entrypoint.sh"]
