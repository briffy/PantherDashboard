<?php
$info['PantherXVer'] = trim(file_get_contents("/var/dashboard/statuses/pantherx_ver"));

if ($info['PantherXVer'] == 'X1') {
	$logs['miner'] = shell_exec('tail -300 /opt/miner_data/log/console.log | tac');
	$logs['witnesses'] = shell_exec('tac /opt/miner_data/log/console.log | grep -E "miner_onion_server:send_witness|client sending data|miner_onion_server[_light]*:decrypt|miner_poc_grpc_client_statem:connected:|send_report witness with onionkeyhash"');
	$logs['errors'] = shell_exec('tail -100 /opt/miner_data/log/error.log | tac');
}

if ($info['PantherXVer'] == 'X2') {
	$logs['miner'] = shell_exec('tail -300 /opt/panther-x2/miner_data/log/console.log | tac');
	$logs['witnesses'] = shell_exec('tac /opt/panther-x2/miner_data/log/console.log | grep -E "miner_onion_server:send_witness|client sending data|miner_onion_server[_light]*:decrypt|miner_poc_grpc_client_statem:connected:|send_report witness with onionkeyhash"');
	$logs['errors'] = shell_exec('tail -100 /opt/panther-x2/miner_data/log/error.log | tac');
}
?>
<h1>Panther <?php echo $info['PantherXVer']; ?> Miner Dashboard - Logs</h1>

<div class="log_container">
<a href="/?page=minerloganalyzer" title="Miner Log Analyzer"><span class="text"><h2>Analysis log with Helium Miner Log Analyzer</span></h2></a>
<a href="/?page=lorapacketforwarderanalyzer" title="Miner Log Analyzer"><span class="text"><h2>Analysis log with LoRa Packet Forwarder Analyzer</span></h2></a>
<div>

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
