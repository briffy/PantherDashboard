<?php
$logs['miner'] = shell_exec('tail -300 /opt/miner_data/log/console.log | tac');
$logs['witnesses'] = shell_exec('tac /opt/miner_data/log/console.log | grep -E "miner_onion_server:send_witness|miner_onion_server:decrypt|client sending data"');
$logs['errors'] = shell_exec('tail -100 /opt/miner_data/log/error.log | tac');
?>
<h1>Panther X1 Miner Dashboard - Information</h1>


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
