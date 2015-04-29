#!/usr/bin/env bash

function debug {
if [ 1 -eq 0 ]; then
  declare -p $1
fi
}

case $1 in
  "" ) hostname="http://www.vpngate.net" ;;
   * ) hostname=$1 ;;
esac

name=VPN-Gate-L2TP-`date +%Y-%m-%d`
output=${name}.mobileconfig
CONNECT_TIMEOUT=10

VPNGATE_MIRRORS=`\
  curl -f -s ${hostname}/en/sites.aspx|\
  grep "^<li><strong><span style='font-size: medium'><a href='"|\
  sed -e "s/<li><strong><span style='font-size: medium'><a href='\([^']*\)\/en\/.*/\1/g"\
  `
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  exit ${PIPESTATUS[0]}
fi

for mirror in ${VPNGATE_MIRRORS}; do
VPNGATE_IP_L2TP=`
  curl -f -s --connect-timeout ${CONNECT_TIMEOUT} ${mirror}/en/ -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Cache-Control: max-age=0' --compressed|\
  grep "^<td class='vg_table_row_[01]' style='text-align: center;'><img src='../images/flags/"|\
  grep L2TP/IPsec|\
  sed 's/$//g'|\
  sed -e "s/.*flags\/\(.\{2\}\)\.png.*<\/td>.*>\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)<.*>\([0-9,]*\)<\/span><\/b><\/td><\/tr>$/\3:\2:\1/g"|\
  sed 's/,//g'|\
  sort -nr|\
  sed 's/^[0-9]*://g'
  `
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  continue
fi
if [ ${#VPNGATE_IP_L2TP[@]} -gt 0 ]; then
  if [ "${VPNGATE_IP_L2TP}" != "" ]; then
    input=${VPNGATE_IP_L2TP}
    break
  fi
fi
done

if [ ${#input[@]} -eq 0 ]; then
  exit 1
fi

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>PayloadContent</key>
	<array>
" > ${output}

uuid0=`uuidgen`
index=0
for host in ${input}; do
  ip=`echo "${host}"|sed 's/:[^:]*//g'`
  country=`echo "${host}"|sed 's/[^:]*://g'`
  uuid1=`uuidgen`
  uuid2=`uuidgen`
  echo "VPN Gate ${index}: ${ip} of ${country}"
  echo "
		<dict>
			<key>IPSec</key>
			<dict>
				<key>AuthenticationMethod</key>
				<string>SharedSecret</string>
				<key>LocalIdentifierType</key>
				<string>KeyID</string>
				<key>SharedSecret</key>
				<data>
				dnBu
				</data>
			</dict>
			<key>IPv4</key>
			<dict>
				<key>OverridePrimary</key>
				<integer>1</integer>
			</dict>
			<key>OverridePrimary</key>
			<integer>1</integer>
			<key>PPP</key>
			<dict>
				<key>AuthName</key>
				<string>vpn</string>
				<key>AuthPassword</key>
				<string>vpn</string>
				<key>CommRemoteAddress</key>
				<string>${ip}</string>
			</dict>
			<key>PayloadDescription</key>
			<string>Configures VPN settings</string>
			<key>PayloadDisplayName</key>
			<string>VPN</string>
			<key>PayloadIdentifier</key>
			<string>vpngate-l2tp-mobileconfig.CF99BEE7-8930-4DA7-B41F-6B4DEB5D9C57.com.apple.vpn.managed.${uuid1}</string>
			<key>PayloadType</key>
			<string>com.apple.vpn.managed</string>
			<key>PayloadUUID</key>
			<string>${uuid2}</string>
			<key>PayloadVersion</key>
			<real>1</real>
			<key>Proxies</key>
			<dict/>
			<key>UserDefinedName</key>
			<string>VPN Gate ${index}: ${country}</string>
			<key>VPNType</key>
			<string>L2TP</string>
		</dict>
" >> ${output}
  index=$((index+1))
done

echo "
	</array>
	<key>PayloadDisplayName</key>
	<string>${name}</string>
	<key>PayloadIdentifier</key>
	<string>vpngate-l2tp-mobileconfig.CF99BEE7-8930-4DA7-B41F-6B4DEB5D9C57</string>
	<key>PayloadRemovalDisallowed</key>
	<false/>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>${uuid0}</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
</plist>
" >> ${output}
