<?php
$info['PantherXVer'] = trim(file_get_contents("/var/dashboard/statuses/pantherx_ver"));

if ($info['PantherXVer'] == 'X1') {
	$logs['miner'] = shell_exec('tail -300 /var/dashboard/logs/helium-miner.log | tac');
	$logs['witnesses'] = shell_exec('tac /var/dashboard/logs/helium-miner.log | grep -E "beacon transmitted | received potential beacon.*len: 52"');
	$logs['errors'] = shell_exec('tail -100 /var/dashboard/logs/helium-miner.log | grep -E "ERRO" | tac');
}

if ($info['PantherXVer'] == 'X2') {
	$logs['miner'] = shell_exec('tail -300 /var/dashboard/logs/helium-miner.log | tac');
	$logs['witnesses'] = shell_exec('tac /var/dashboard/logs/helium-miner.log | grep -E "beacon transmitted | received potential beacon.*len: 52"');
	$logs['errors'] = shell_exec('tail -100 /var/dashboard/logs/helium-miner.log | grep -E "ERRO" | tac');
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
