<?php
$setTimezone = trim(html_entity_decode($_POST['settimezone']));

if ($setTimezone != "") {
	$timezoneFile = fopen("/var/dashboard/timezone_config", "w");
	fwrite($timezoneFile, $setTimezone);

	echo 'set timezone sucessfully';
}
else
{
	echo 'invalid timezone';
}
?>
