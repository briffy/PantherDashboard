<?php
/**
 * minerloganalyzer.php
 *
 * Extracts witness data from Helium miner logs
 *
 * @author     Iñigo Flores
 * @copyright  2022 Iñigo Flores
 *             2022 Fengling
 * @license    https://opensource.org/licenses/MIT  MIT License
 * @version    0.01
 * @link       https://github.com/inigoflores/helium-miner-log-analyzer
 */

$logsFolder = './';

$info['PantherXVer'] = trim(file_get_contents("/var/dashboard/statuses/pantherx_ver"));

echo "<h1>Panther ".$info['PantherXVer']." Miner Dashboard - Miner Log Analyzer</h1>";

if ($info['PantherXVer'] == 'X1') {
	$logsFolder = '/opt/miner_data/log/';
}

if ($info['PantherXVer'] == 'X2') {
	$logsFolder = '/opt/panther-x2/miner_data/log/';
}

$startDate = "2000-01-01";
$endDate = "2030-01-01";

// Command line options
$options = ["p:","s:","e:","a","l","c::"];
$opts = getopt(implode("",$options));

// Defaults to stats when called
if (!(isset($opts['l']) || isset($opts['c']))) {
	$opts['a']=true;
}

foreach ($options as $key=>$val){
	$options[$key] = str_replace(":","",$val);
}

uksort($opts, function ($a, $b) use ($options) {
	$pos_a = array_search($a, $options);
	$pos_b = array_search($b, $options);
	return $pos_a - $pos_b;
});


// Handle command line arguments
foreach (array_keys($opts) as $opt) switch ($opt) {
case 'p':
	$logsFolder = $opts['p'];
	if (substr($logsFolder,strlen($logsFolder)-1) != "/"){
		$logsFolder.="/";
	};
	break;
case 's':
	if (!DateTime::createFromFormat('Y-m-d',  $opts['s'])){
		echo "Wrong date format";
		break;
	}
	$startDate = $opts['s'];
	break;
case 'e':
	if (!DateTime::createFromFormat('Y-m-d',  $opts['e'])){
		echo "Wrong date format";
		break;
	}
	$endDate = $opts['e'];
	break;
case 'a':
	echo "<div class=\"log_container\">";
	echo "\nUsing logs in folder {$logsFolder}\n\n";
	$beacons = extractData($logsFolder,$startDate,$endDate);
	echo generateStats($beacons);
	echo generateList($beacons);
	echo "</div>";
	break;

case 'l':
	echo "<div class=\"log_container\">";
	echo "\nUsing logs in folder {$logsFolder}\n\n";
	$beacons = extractData($logsFolder,$startDate,$endDate);
	echo generateList($beacons);
	echo "</div>";
	break;

case 'c':
	echo "<div class=\"log_container\">";
	$beacons = extractData($logsFolder,$startDate,$endDate);
	$filename = $opts['c'];
	echo generateCSV($beacons,$filename);
	echo "</div>";
	break;
}

/*
 * -------------------------------------------------------------------------------------------------
 * Functions
 * -------------------------------------------------------------------------------------------------
 */

/**
 * @param $beacons
 * @return string
 */
function generateStats($beacons) {


	if (empty($beacons)) {
		return '<br><br><br><h2>No witnesses found</h2>';
	}

	$startTime = DateTime::createFromFormat('Y-m-d H:i:s',explode('.',$beacons[0]['datetime'])[0]);
	$endTime = DateTime::createFromFormat('Y-m-d H:i:s',explode('.',end($beacons)['datetime'])[0]);
	$intervalInHours = ($endTime->getTimestamp() - $startTime->getTimestamp())/3600;

	$successful = 0;
	$failedMaxRetry = 0;
	$failedIncomplete = 0;
	$failedUnkown = 0;

	$failedNotFound = 0;
	$failedTimeout = 0;
	$failedNoListenAddress = 0;
	$failedConRefused = 0;
	$failedHostUnreach = 0;

	$relayed = 0;
	$notRelayed = 0;

	foreach ($beacons as $beacon){

		// General Witnesses Overview
		if ($beacon['status']=='successfully sent') {
			$successful++;
		} else if ($beacon['status']=='failed max retry') {
			$failedMaxRetry++;
		} else if ($beacon['status']=='failed to dial' || $beacon['status']=='incomplete') {
			$failedIncomplete++;
		} else {
			$failedUnkown++;
		}

		// Failure Reasons
		if ($beacon['status']=='failed max retry') {
			if (!empty($beacon['reasonShort'])) {
				if ($beacon['reasonShort']=='not found') {
					$failedNotFound++;
				} else if ($beacon['reasonShort']=='timeout') {
					$failedTimeout++;
				} else if ($beacon['reasonShort']=='no listen address') {
					$failedNoListenAddress++;
				} else if ($beacon['reasonShort']=='connection refused') {
					$failedConRefused++;
				} else if ($beacon['reasonShort']=='host unreachable') {
					$failedHostUnreach++;
				}
			}
		}

		//Relayed Challengers
		if (@$beacon['relayed'] == "yes") {
			$relayed++;
		} else if (@$beacon['relayed'] == "no") {
			$notRelayed++;
		}
	}

	$total = sizeOf($beacons);
	$totalFailed = $total - $successful;
	$totalPerHour = round($total / $intervalInHours,2);

	$totalFailedOther = $failedNoListenAddress +  $failedConRefused + $failedHostUnreach;

	$percentageSuccessful = round($successful/$total*100,2);
	$percentageFailed = round($totalFailed/$total*100,2);
	$percentageFailedMaxRetry = round($failedMaxRetry/$total*100,2);
	$percentageFailedIncomplete = round($failedIncomplete/$total*100,2);

	$percentageFailedNotFound = round($failedNotFound/$total*100,2);
	$percentageFailedTimeout = round($failedTimeout/$total*100,2);
	$percentageFailedOther = round($totalFailedOther/$total*100,2);


	$percentageNotRelayed = round($notRelayed/$total*100,2);
	$percentageRelayed = round($relayed/$total*100,2);
	$percentageRelayUnknown = round(($total-$notRelayed-$relayed)/$total*100,2);
	$Unknown = $total - $notRelayed - $relayed;

	$output = '<br><br><p><br><h2 style="color:#AED6F1;">General Witnesses Overview</h2></p><br>';
	$output.='<table border="1" style="width: 100%; height: 100%">';
	$output.= "
		<tr border='1' align='left' style='color:#FCF3CF ;' >
		<th style='width:60%'> Description </th>
		<th align='center'> Value </th>
		<th align='center'> Precentage </th>
		</tr>";
	$output.= "
		<tr border='1'>
			<td> Total witnesses </td>
			  <td align='center'> {$total} </td>
			 <td align='center'> {$totalPerHour} / hour  </td>
		</tr>";
	$output.= "
		<tr border='1'>
			<td> Succesfully delivered  </td>
			<td align='center'> {$successful} </td>
			 <td align='center'> {$percentageSuccessful} %</td>
		</tr> ";
	$output.= "
		<tr border='1'>
			<td> Failed  </td>
			 <td align='center'> {$totalFailed} </td>
			 <td align='center'> {$percentageFailed}% </td>
		</tr> ";
	$output.= "
		<tr border='1'>
			<td> ├── Max retry </td>
			<td align='center'> {$failedMaxRetry} </td>
			<td align='center'> {$percentageFailedMaxRetry}% </td>
		</tr> ";
     $output.= "
		<tr border='1'>
			<td> └── Crash/reboot </td>
			<td align='center'> {$failedIncomplete} </td>
			<td align='center'> {$percentageFailedIncomplete}% </td>
		</tr> ";
	$output.= " </table>";
	$output .=  '<br><p><br><h2 style="color:#AED6F1;"> Max Retry Failure Reasons </h2></p><br>';
	$output.='<table border="1" style="width: 100%; height: 100%">';
	$output.= "
		<tr border='1' align='left' style='color:#FCF3CF ;' >
		<th style='width:60%'>Description </th>
		<th align='center'> Value  </th>
		<th align='center'> Precentage </th>
		</tr>";
	$output.= "
		<tr border='1'>
			<td> Timeout </td>
			  <td align='center'> {$failedTimeout} </td>
			 <td align='center'> {$percentageFailedTimeout}%  </td>
		</tr>";
	$output.= "
		<tr border='1'>
			<td> Not Found  </td>
			<td align='center'> {$failedNotFound} </td>
			 <td align='center'> {$percentageFailedNotFound}%</td>
		</tr> ";
	$output.= "
		<tr border='1'>
			<td> Other challenger issues   </td>
			 <td align='center'> {$totalFailedOther} </td>
			 <td align='center'> {$percentageFailedOther}% </td>
		</tr> ";

	$output.= " </table>";


	$output .=  '<br><p><br><h2 style="color: #AED6F1;"> Challengers </h2></p><br>';
	$output.='<table border="1" style="width: 100%; height: 100%">';
	$output.= "
		<tr border='1' align='left' style='color:#FCF3CF ;' >
		<th style='width:60%'> Description </th>
		<th align='center'> Value </th>
		<th align='center'> Precentage </th>
		</tr>";
	$output.= "
		<tr border='1'>
			<td> Not Relayed  </td>
			  <td align='center'> {$notRelayed} </td>
			 <td align='center'>  {$percentageNotRelayed}%  </td>
		</tr>";
	$output.= "
		<tr border='1'>
			<td> Relayed  </td>
			<td align='center'> {$relayed} </td>
			 <td align='center'> {$percentageRelayed}%</td>
		</tr> ";
	$output.= "
		<tr border='1'>
			<td> Unknown (Probably Not Relayed)   </td>
			 <td align='center'> {$Unknown } </td>
			 <td align='center'> {$percentageRelayUnknown}% </td>
		</tr> ";

	$output.= " </table>";

	return $output;
}

/**
 * @param $beacons
 * @return string
 */
function generateList($beacons) {

	if (empty($beacons)) {
		return;
	}
	$output = '<br><p><br><h2 style="color:#AED6F1;">Witnesses List</h2></p>';
	$output .= '<br>
		<table border="1" style="width: 100%; height: 100%">
		<tr style="color:#FCF3CF ;">
		<th align="left">Date</th>
		<th>RSSI</th>
		<th>Freq</th>
		<th>SNR</th>
		<th>Noise</th>
		<th>Relay</th>
		<th>Status</th>
		<th>Fails</th>
		<th>Reason</th>
		</tr>';

	foreach (array_reverse($beacons) as $beacon){

		$rssi = str_pad($beacon['rssi'], 4, " ", STR_PAD_LEFT);
		$snr = str_pad($beacon['snr'], 5, " ", STR_PAD_LEFT);
		$noise = str_pad(number_format((float) ($beacon['rssi'] - $beacon['snr']),1),6,  " ", STR_PAD_LEFT);
		$status = str_pad($beacon['status'], 17, " ", STR_PAD_RIGHT);
		$failures = str_pad(empty($beacon['failures'])?0:$beacon['failures'], 5, " ", STR_PAD_LEFT);
		$challenger = @str_pad($beacon['challenger'],52, " ", STR_PAD_RIGHT);
		$relayed = @str_pad($beacon['relayed'],5, " ", STR_PAD_RIGHT);
		$reasonShort = @$beacon['reasonShort'];
		$reason = @$beacon['reason'];
		$session = str_pad($beacon['session'],11, " ", STR_PAD_LEFT);;

		$dt = new DateTime($beacon['datetime']);
		$dt->modify('+4 hours');

		$output.=@"
		<tr border='1'>
			<td> {$dt->format('M-d H:i:s')} </td>
			<td> {$rssi} </td>
			<td> {$beacon['freq']} </td>
			<td> {$snr} </td>
			<td> {$noise} </td>
			<td> $relayed </td>
			<td> {$status} </td>
			<td> {$failures} </td>
			<td> {$reasonShort} </td>
		</tr>";
	}

	return $output."</table>";
}
function generateList2($beacons) {
	$output = "<br><br>Date                    | RSSI | Freq  | SNR   | Noise                                             | Relay | Status            | Fails | Reason <br>";
	$output.= "------------------------------------------------------------------------------------ <br>";

	foreach ($beacons as $beacon){

		$rssi = str_pad($beacon['rssi'], 4, " ", STR_PAD_LEFT);
		$snr = str_pad($beacon['snr'], 5, " ", STR_PAD_LEFT);
		$noise = str_pad(number_format((float) ($beacon['rssi'] - $beacon['snr']),1),6,  " ", STR_PAD_LEFT);
		$status = str_pad($beacon['status'], 17, " ", STR_PAD_RIGHT);
		$failures = str_pad(empty($beacon['failures'])?0:$beacon['failures'], 5, " ", STR_PAD_LEFT);
		$challenger = @str_pad($beacon['challenger'],52, " ", STR_PAD_RIGHT);
		$relayed = @str_pad($beacon['relayed'],5, " ", STR_PAD_RIGHT);
		$reasonShort = @$beacon['reasonShort'];
		$reason = @$beacon['reason'];
		$session = str_pad($beacon['session'],11, " ", STR_PAD_LEFT);;


		$dt = new DateTime($beacon['datetime']);
		$dt->modify('+4 hours');

		$output.=@"{$dt->format('M-d H:i:s')} | {$rssi} | {$beacon['freq']} | {$snr} | {$noise} |  $relayed | {$status} | {$failures} | {$reasonShort} <br>";

	}
	return $output;
}

/**
 * @param $logsFolder
 * @return array
 */
function extractData($logsFolder, $startDate, $endDate){

	$beacons = [];
	$filenames = glob("{$logsFolder}console*.log*");

	if (empty($filenames)){
		echo "No logs found. Please chdir to the Helium miner logs folder or specify a path.\n";
		return $beacons;
	}

	rsort($filenames); //Order is important, from older to more recent.

	foreach ($filenames as $filename) {

		$buf = file_get_contents($filename,);
		if(substr($filename, -3) == '.gz') {
			$buf = gzdecode($buf);
		}

		$lines = explode("\n", $buf);
		unset($buf);

		foreach ($lines as $line) {

			if (preg_match('/miner_onion_server:send_witness:{[0-9]+,[0-9]+} (?:re-)?sending witness at RSSI/', $line) ||
				preg_match('/miner_onion_server:send_witness:{[0-9]+,[0-9]+} failed to dial challenger/', $line) ||
				preg_match('/miner_onion_server:send_witness:{[0-9]+,[0-9]+} successfully sent witness to challenger/', $line) ||
				preg_match('/miner_onion_server:send_witness:{[0-9]+,[0-9]+} failed to send witness, max retry/', $line) ||
				preg_match('/libp2p_transport_relay:connect_to:{[0-9]+,[0-9]+} init relay transport with/', $line)
			)
			{
				$fields = explode(' ', $line);
				$datetime = $fields[0] . " " . $fields[1];
				if ($datetime<$startDate || $datetime>$endDate) {
					continue;
				}
				$session = explode('>',explode('<', $fields[4])[1])[0];
			} else {
				continue;
			}

			if (preg_match('/sending witness at RSSI/', $line)){
				$rssi = str_pad(substr($fields[9], 0, -1), 4, " ", STR_PAD_LEFT);
				$freq = substr($fields[11], 0, -1);
				$snr = $fields[13];
				$status = "incomplete";
				$beacons[$session] = array_merge((array)@$beacons[$session], compact('datetime', 'session', 'rssi', 'freq', 'snr', 'status'));
				continue;
			}

			if (preg_match('/failed to dial challenger/', $line)) {
				$challenger = substr($fields[9], 6, -2);
				$reason = $fields[10];
				if (strpos($line,'p2p-circuit')){
					$relayed = 'yes';
				} else {
					$relayed = 'no';
				}

				switch (true) {
				case strpos($reason,'not_found') !== FALSE:
					$reasonShort = "not found";
					break;
				case strpos($reason,'timeout') !== FALSE:
					$reasonShort = "timeout";
					break;
				case strpos($reason,'econnrefused') !== FALSE:
					$reasonShort = "connection refused";
					break;
				case strpos($reason,',ehostunreach') !== FALSE:
					$reasonShort = "host unreachable";
					break;
				case strpos($reason,'no_listen_addr') !== FALSE:
					$reasonShort = "no listen address";
					break;
				default:
					$reasonShort = "";
				};

				$failures = @$beacons[$session]['failures'] + 1;
				$status = "failed to dial";
				$beacons[$session] = array_merge((array)@$beacons[$session], compact('datetime', 'session', 'challenger', 'status', 'reason','reasonShort', 'relayed','failures'));
				continue;
			}

			if (preg_match('/successfully sent witness to challenger/', $line)) {
				$challenger = substr($fields[10], 6, -1);
				$rssi = str_pad(substr($fields[13], 0, -1), 4, " ", STR_PAD_LEFT);
				$freq = substr($fields[15], 0, -1);
				$snr = $fields[17];
				$status = "successfully sent";
				$reason = "";
				$reasonShort = "";
				$beacons[$session] = array_merge((array)@$beacons[$session], compact('datetime', 'session', 'challenger', 'rssi', 'freq', 'snr', 'status', 'reason','reasonShort'));
				continue;
			}

			if (preg_match('/failed to send witness, max retry/', $line)) {

				$status = "failed max retry";
				$beacons[$session] = array_merge((array)@$beacons[$session], compact('datetime', 'session', 'status'));
				continue;
			}

			if (preg_match('/init relay transport/', $line)) {
				$relayed = 'yes';
				$beacons[$session] = array_merge((array)@$beacons[$session], compact('relayed'));
			}
		}
	}
	//
	foreach ($beacons as $session => $beacon) {
		if (empty(@$beacon['rssi'])) {
			unset($beacons[$session]);
		}
	}

	usort($beacons, function($a, $b) {
		return $a['datetime'] <=> $b['datetime'];
	});

	return $beacons;
}


/**
 * @param $beacons
 * @return string
 */
function generateCSV($beacons, $filename=false) {
	$columns = ['Date','Session','RSSI','Freq','SNR','Noise','Challenger','Relay','Status','Fails','Reason'];
	$data = array2csv($columns);
	foreach ($beacons as $beacon){
		$noise = number_format((float) ($beacon['rssi'] - $beacon['snr']),1);
		$failures = empty($beacon['failures'])?0:$beacon['failures'];
		$data.= @array2csv([
			$beacon['datetime'],$beacon['session'],$beacon['rssi'],
			$beacon['freq'],$beacon['snr'],$noise,$beacon['challenger'],
			$beacon['relayed'],$beacon['status'],$failures,$beacon['reasonShort']]);

	}

	if ($filename) {
		$data = "SEP=;" . $data;
		file_put_contents($filename,$data);
		return "Data saved to $filename\n";
	}

	return $data;

}

/**
 * @param $fields
 * @param string $delimiter
 * @param string $enclosure
 * @param string $escape_char
 * @return false|string
 */
function array2csv($fields, $delimiter = ",", $enclosure = '"', $escape_char = '\\')
{
	$buffer = fopen('php://temp', 'r+');
	fputcsv($buffer, $fields, $delimiter, $enclosure, $escape_char);
	rewind($buffer);
	$csv = fgets($buffer);
	fclose($buffer);
	return $csv;
}

