#!/usr/bin/env bash

case $1 in
  "" ) exit 1 ;;
   * ) hostname=$1 ;;
esac

curl -s ${hostname}/en/ -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Cache-Control: max-age=0' --compressed|grep "^<td class='vg_table_row_[01]' style='text-align: center;'><img src='../images/flags/"|grep L2TP/IPsec|sed -e 's/.*>\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)<.*/\1/g'
