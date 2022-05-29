<?php
if((isset($_POST['SSID']) && isset($_POST['password']) && isset($_POST['country'])) && ($_POST['SSID'] != '' && $_POST['password'] != "" && $_POST['country'] != ""))
{
$config = "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\n
update_config=1
country=".trim(html_entity_decode($_POST['country']))."

network={
	ssid=\"".trim(html_entity_decode($_POST['SSID']))."\"
	psk=\"".trim(html_entity_decode($_POST['password']))."\"
	scan_ssid=1
}\n";
	$file = fopen("/var/dashboard/wifi_config", "w");
	fwrite($file, $config);
	fclose($file);
	echo 'WiFi config written, please wait at least 30 seconds and reboot.';
}
else
{
	echo 'Error, please try again.';
}
?>
