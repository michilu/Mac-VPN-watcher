#!/usr/bin/env bash

name=VPN-Gate-L2TP-`date +%Y-%m-%d`
uuid0=`uuidgen`
output=${name}.mobileconfig

read -rd '' input

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>PayloadContent</key>
	<array>
" > ${output}

index=0
for ip in ${input}; do
  uuid1=`uuidgen`
  uuid2=`uuidgen`
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
	    <string>VPN Gate ${index}</string>
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
