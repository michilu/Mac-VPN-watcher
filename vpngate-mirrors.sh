#!/usr/bin/env bash

case $1 in
  "" ) hostname="http://www.vpngate.net" ;;
   * ) hostname=$1 ;;
esac

curl -s ${hostname}/en/sites.aspx|grep "^<li><strong><span style='font-size: medium'><a href='"|sed -e "s/<li><strong><span style='font-size: medium'><a href='\([^']*\)\/en\/.*/\1/g"
