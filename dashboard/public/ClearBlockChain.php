<?php
if($_POST['confirm'])
{
	exec("sudo docker stop helium-miner");
	exec("sudo rm -rf /opt/miner_data/blockchain.db/*");
	exec("sudo rm -rf /opt/miner_data/ledger.db/*");
	exec("sudo docker start helium-miner");
	echo 'Blockchain data cleared.';
}
