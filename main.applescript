on isOnline()
	try
		do shell script "curl -s -I --connect-timeout 10 http://sample.appspot.com/"
		return true
	on error errStr
		return false
	end try
end isOnline
on setOrderService()
	set orderVPN to do shell script "networksetup -listnetworkserviceorder |grep '^([0-9]'|nl|grep '^ *[0-9]*	*([0-9]*) VPN.*$'|tail -n 1|awk '{print $1}'"
	set orderWiFi to do shell script "networksetup -listnetworkserviceorder |grep '^([0-9]'|nl|grep '^ *[0-9]*	*([0-9]*) Wi-Fi$'|awk '{print $1}'"
	if not orderVPN < orderWiFi then
		do shell script "echo networksetup -ordernetworkservices `networksetup -listnetworkserviceorder |grep '^([0-9]'|sed -e 's/([0-9]*) //g'|grep -v '^Wi-Fi$'|sed 's/.*/\"&\"/'|tr '
' ' '` Wi-Fi|sh"
	end if
end setOrderService

on idle
	set status to do shell script "/usr/sbin/networksetup -getairportpower en0 | awk '{ print $4 }'"
	if status is not "On" then
		return 120
	end if
	set ssid to do shell script "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print $2}'"
	if ssid is "" then
		return 120
	end if
	if isOnline() then
		return 30
	end if
	setOrderService()
	set listnetwork to do shell script "networksetup -listnetworkserviceorder |grep '^([0-9]'|sed -e 's/([0-9]*) //g'|grep '^VPN'|tr '
' '/'"
	set text item delimiters of AppleScript to "/"
	set serviceNames to rest of reverse of text items of listnetwork
	tell application "System Events"
		tell current location of network preferences
			repeat with serviceName in serviceNames
				set VPN to null
				try
					set VPN to service serviceName
				on error errStr
					log errStr
					set VPN to null
				end try
				if VPN is not null then
					if active of VPN is true then
						set isConnected to false
						try
							set isConnected to (VPN is connected)
						on error errStr
							log serviceName & ": " & errStr
						end try
						if isConnected then
							return 30
						end if
					end if
				end if
			end repeat
			repeat with serviceName in serviceNames
				set VPN to null
				try
					set VPN to service serviceName
				on error errStr
					log serviceName & ": " & errStr
					set VPN to null
				end try
				if VPN is not null then
					if active of VPN is true then
						connect VPN
						delay 30
						try
							do shell script "curl -s -I --connect-timeout 10 http://sample.appspot.com/"
							return 30
						on error errStr
						end try
					end if
				end if
			end repeat
		end tell
	end tell
end idle