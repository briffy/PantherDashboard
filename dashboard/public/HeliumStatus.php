<?php
	shell_exec("/var/dashboard/monitor-scripts/helium-statuses.sh");
	$live_height = trim(file_get_contents('/var/dashboard/statuses/current_blockheight'));
	$online_status = trim(file_get_contents("/var/dashboard/statuses/online_status"));
	$miner_height = trim(file_get_contents("/var/dashboard/statuses/infoheight"));

	header('Content-Type:application/json; charset=utf-8');
	$arr = array('live_height'=>$live_height,'online_status'=>$online_status,'miner_height'=>$miner_height);

	echo json_encode($arr);
?>
