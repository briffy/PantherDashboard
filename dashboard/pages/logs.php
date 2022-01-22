<?php
$logs['miner'] = shell_exec('docker exec helium-miner tail -300 /var/data/log/console.log | tac');
$logs['witnesses'] = shell_exec('docker exec helium-miner  tac /var/data/log/console.log | grep -E "miner_onion_server:send_witness|miner_onion_server:decrypt|client sending data"');
$logs['errors'] = shell_exec('docker exec helium-miner tail -100 /var/data/log/error.log | tac');
$info['PantherXVer'] = trim(file_get_contents("/var/dashboard/statuses/pantherx_ver"));
?>
<h1>Panther <?php $info['PantherXVer']; ?> Miner Dashboard - Logs</h1>

<div class="log_container">
	<h2>Miner Logs</h2>
	<div class="wrapper"><textarea class="log_output" wrap="off"><?php echo $logs['miner']; ?></textarea></div>
</div>

<div class="log_container">
	<h2>Witness Logs</h2>
	<div class="wrapper"><textarea class="log_output" wrap="off"><?php echo $logs['witnesses']; ?></textarea></div>
</div>

<div class="log_container">
	<h2>Error Logs</h2>
	<div class="wrapper"><textarea class="log_output" wrap="off"><?php echo $logs['errors']; ?></textarea></div>
</div>
