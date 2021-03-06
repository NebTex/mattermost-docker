#!/usr/bin/dumb-init /bin/bash
{{ if (env "VAULT_ADDR") }}
{{ with printf "aws/creds/%s" (env "APP_ROLE") | secret }}
AWS_ACCESS_KEY_ID={{ .Data.access_key }}
AWS_SECRET_ACCESS_KEY={{ .Data.secret_key }}
{{ end }}
{{ with printf "postgresql/creds/%s" (env "APP_ROLE") | secret }}
DB_USERNAME={{ .Data.username }}
DB_PASSWORD={{ .Data.password }}
{{ end }}
{{ end }}

DB_HOST={{ printf "Settings/NameSpaces/%s/AppRoles/%s/DB/HOST" (env "NAMESPACE") (env "APP_NAME") | key }} 
DB_PORT={{ printf "Settings/NameSpaces/%s/AppRoles/%s/DB/PORT" (env "NAMESPACE") (env "APP_NAME") | key }} 
DB_NAME={{ printf "Settings/NameSpaces/%s/AppRoles/%s/DB/NAME" (env "NAMESPACE") (env "APP_NAME") | key }} 

initialConfig=/tmp/config.json
config=/mattermost/config/config.json
yes | \cp -rf $initialConfig $config 

sed -Ei "s/DB_USERNAME/${DB_USERNAME}/" $config
sed -Ei "s/DB_PASSWORD/${DB_PASSWORD}/" $config
sed -Ei "s/DB_HOST/${DB_HOST}/" $config
sed -Ei "s/DB_PORT/${DB_PORT}/" $config
sed -Ei "s/DB_NAME/${DB_NAME}/" $config
sed -Ei "s@AWS_ACCESS_KEY_ID@${AWS_ACCESS_KEY_ID}@" $config
sed -Ei "s@AWS_SECRET_ACCESS_KEY@${AWS_SECRET_ACCESS_KEY}@" $config
sed -Ei 's/"true"/true/' $config
sed -Ei 's/"false"/false/' $config
sed -Ei 's/"([0-9]+)"/\1/' $config
sed -Ei "s/'([0-9]+)'/\1/" $config

printf ${DB_HOST:?} > /etc/db_host
printf ${DB_PORT:?} > /etc/db_port
printf ${DB_NAME:?} > /etc/db_name


supervisorctl restart mattermost