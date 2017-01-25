#!/usr/bin/dumb-init /bin/sh

set -e

[ -z $APP_NAME ] && { echo "Need to set APP_NAME"; exit 1; }
[ -z $NAMESPACE ] && { echo "Need to set NAMESPACE"; exit 1; }

printf $APP_NAME > /etc/app_name
printf $NAMESPACE > /etc/namespace

supervisord -n