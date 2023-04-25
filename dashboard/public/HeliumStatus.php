<?php
    if ( filesize('/var/dashboard/logs/helium-miner.log') == 0 ) {
        include('/var/dashboard/pages/helium-miner-log.php');
	}
	shell_exec("/etc/monitor-scripts/helium-statuses.sh");
	$info['LatestMinerVersion'] = trim(file_get_contents('/var/dashboard/statuses/latest_miner_version'));
	$online_status = trim(file_get_contents("/var/dashboard/statuses/online_status"));

	// Light version: https://engineering.helium.com/2022/05/10/miner-firmware-hotspot-release.html
	if ($info['LatestMinerVersion'] != '') {
		if ($online_status == 'offline') {
			$online_status = 'inactive';
		}
		if ($online_status == 'online') {
			$online_status = 'active';
		}
	}

	header('Content-Type:application/json; charset=utf-8');

	echo '{"online_status":"'.ucwords($online_status).'"}';
?>
