<?php
/**
 * lorapacketforwarderanalyzer.php
 *
 * Extracts witness data from lora packet forwarder
 *
 * @author     Iñigo Flores
 * @copyright  2022 Iñigo Flores
 *             2022 Fengling
 * @license    https://opensource.org/licenses/MIT  MIT License
 * @version    0.02
 * @link       https://github.com/inigoflores/lora-packet-forwarder-analyzer
  */

$logsPath = '/var/log/packet-forwarder/packet_forwarder.log';


$startDate = "2000-01-01";
$endDate = "2030-01-01";
$includeDataPackets = false;

// Command line options
$options = ["t","d","p:","s:","e:","c::","a","l","i"];
$opts = getopt(implode("",$options));

// Defaults to stats when called
if (!(isset($opts['l']) || isset($opts['c']) || isset($opts['i']))) {
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

$showPayloadData = $csvOutput = false;

// Handle command line arguments
foreach (array_keys($opts) as $opt) switch ($opt) {
    case 'p':
        $logsPath = $opts['p'];
        if (substr($logsPath,strlen($logsPath)-1) != "/" && is_dir($logsPath)){
            $logsPath.="/";
        };
        break;
    case 'd':
        $includeDataPackets = true;
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
    case 'c':
        $csvOutput = true;
        $filename = $opts['c'];
        break;
    case 't':
        $showPayloadData = true;
        break;
    case 'a':
        echo "<div class=\"log_container\">";
        echo "\nUsing logs in {$logsPath}\n\n";
        $packets = extractData($logsPath,$startDate,$endDate);
        echo generateStats($packets);
        echo generateList($packets,$includeDataPackets,$showPayloadData);
        echo "</div>";
        break;
    case 'l':
        echo "<div class=\"log_container\">";
        echo "\nUsing logs in {$logsPath}\n\n";
        $packets = extractData($logsPath,$startDate,$endDate);
        if (!$csvOutput) {
            echo generateList($packets,$includeDataPackets,$showPayloadData);
        } else {
            echo generateCSV($packets,$filename,$includeDataPackets, $showPayloadData);
        }
        echo "</div>";
        break;
    case 'i':
        echo "<div class=\"log_container\">";
        echo "\nUsing logs in {$logsPath}\n\n";
        $packets = extractData($logsPath,$startDate,$endDate);
        $histogram = generateHistogramData($packets,$includeDataPackets);
        if (!$csvOutput) {
            echo generateHistogramASCIIChart($histogram,$includeDataPackets,$showPayloadData);
        } else {
            echo generateCSVHistogram($histogram,$filename,$includeDataPackets,$showPayloadData);
        }
        echo "</div>";
        break;
}


/*
 * -------------------------------------------------------------------------------------------------
 * Functions
 * -------------------------------------------------------------------------------------------------
 */

/**
 * @param $logsPath
 * @return array
 */
function extractData($logsPath, $startDate = "", $endDate = ""){
    $packets = [];
    if (is_dir($logsPath)) {
        $filenames = glob("{$logsPath}packet_forwarder*.log*");
    } else if (is_file($logsPath)) {
        $filenames = [$logsPath];
    } else {
        echo "Path is not a valid folder or file.\n";
        return $packet;
    }

    if (empty($filenames)){
        echo "No logs found. Install the service and let it run for some time before running this command again.\n";
        return $packet;
    }

    rsort($filenames); //Order is important, from older to more recent.

    foreach ($filenames as $filename) {

        $buf = file_get_contents($filename,);
        if (substr($filename, -3) == '.gz') {
            $buf = gzdecode($buf);
        }

        $lines = explode("\n", $buf);
        unset($buf);

        foreach ($lines as $line) {

            if (!strpos($line,'xpk"')) { //empty line
                continue;
            }

            $jsonStart = strpos($line,"{");
            $jsonData = substr($line,$jsonStart);
            //$temp = explode('{"rxpk":', $line);
            $temp = explode(" ",substr($line,0,$jsonStart));
            $datetime = "{$temp[0]} $temp[1]";

            if ($datetime < $startDate || $datetime > $endDate) {
                continue;
            }

            $packet = json_decode($jsonData);

            if (empty($packet)) {
                 continue;
            }

            if (isset($packet->rxpk)) {
                foreach ($packet->rxpk as $packet) {
                    $decodedData = base64_decode($packet->data);

                    if (isset($packet->rssis)) {
                        $rssi = $packet->rssis;
                    } else {
                        $rssi = $packet->rssi;
                    }

                    if (substr($packet->data, 0, 3) == "QDD" && strlen($decodedData) == 52) {
                        $type = "witness";
                        //LongFi packet. The Onion Compact Key starts at position 12 and is 33 bytes long. THanks to @ricopt5 for helping me figure this out.
                        $onionCompactKey = substr($decodedData, 12, 33);
                        $hash = base64url_encode(hash('sha256', $onionCompactKey, true)); // This is the Onion Key Hash
                    } else {
                        $type = "rx data";
                        $hash = base64url_encode(hash('crc32b', $decodedData, true)); //
                    }

                    $snr = $packet->lsnr;
                    $freq = $packet->freq;
                    $datarate = $packet->datr;
                    $data = $packet->data;
                    $packets[] = compact('datetime', 'freq', 'rssi', 'snr', 'type', 'hash', 'datarate','data');
                }
            } else if (isset($packet->txpk))  { //Sent beacon
                $packet = $packet->txpk;
                $decodedData = base64_decode($packet->data);

                $rssi = $packet->powe;

                if (substr($packet->data, 0, 3) == "QDD" && strlen($decodedData) == 52) {
                    $type = "beacon";
                    $onionCompactKey = substr($decodedData, 12, 33);
                    $hash = base64url_encode(hash('sha256', $onionCompactKey, true)); // This is the Onion Key Hash
                } else {
                    $type = "tx data";
                    $hash = base64url_encode(hash('crc32b', $decodedData, true)); //

                }
                $freq = $packet->freq;
                $snr = "";
                $datarate = $packet->datr;
                $data = $packet->data;
                $packets[] = compact('datetime', 'freq', 'rssi', 'snr', 'type', 'hash', 'datarate','data');
            }
        }
    }

    //Sort packets by datetime
    usort($packets, function($a, $b) {
        return $a['datetime'] <=> $b['datetime'];
    });

    return $packets;
}


/**
 * @param $packets
 * @return string
 */
function generateStats($packets) {

    if (empty($packets)) {
        return("<br><br><br><h2>No packets found</h2>");
    }

    $systemDate = new DateTime();

    $startTime = DateTime::createFromFormat('Y-m-d H:i:s',$packets[0]['datetime'], new DateTimeZone( 'UTC' ));
    $endTime = DateTime::createFromFormat('Y-m-d H:i:s',end($packets)['datetime'], new DateTimeZone( 'UTC' ));
    $intervalInHours = ($endTime->getTimestamp() - $startTime->getTimestamp())/3600;
    $intervalInHours = $intervalInHours ? $intervalInHours : 1;
    $intervalInDays = ($endTime->getTimestamp() - $startTime->getTimestamp())/3600/24;
    $intervalInDays = $intervalInDays ? $intervalInDays : 1;

    $startTime->setTimezone($systemDate->getTimezone());
    $endTime->setTimezone($systemDate->getTimezone());

    $totalWitnesses = $totalBeacons = 0;
    $totalPackets = sizeOf($packets);
    $lowestWitnessRssi = $lowestPacketRssi = 0;

    $witnessDataByFrequency = [];
    foreach ($packets as $packet){

        if ($packet['type']=='tx data') {
            continue;

        } else if ($packet['type']=='beacon') {
            $totalBeacons++;
            continue;
        }

        $packetDataByFrequency["{$packet['freq']}"]['rssi'][] = $packet['rssi'];
        $packetDataByFrequency["{$packet['freq']}"]['snr'][] = $packet['snr'];

        if ($packet['rssi'] < $lowestPacketRssi) {
            $lowestPacketRssi = $packet['rssi'];
        }

        if ($packet['type']=='witness') {
            $totalWitnesses++;
            $witnessDataByFrequency["{$packet['freq']}"]['rssi'][] = $packet['rssi'];
            $witnessDataByFrequency["{$packet['freq']}"]['snr'][] = $packet['snr'];

            if ($packet['rssi'] < $lowestWitnessRssi) {
                $lowestWitnessRssi = $packet['rssi'];
            }
        }
    }
    foreach ($packetDataByFrequency as $freq => $rssifreq) {
        $packetRssiAverages["{$freq}"] = number_format(getMean($packetDataByFrequency["{$freq}"]['rssi']),2);
        $packetRssiMins["{$freq}"] = number_format(min($packetDataByFrequency["{$freq}"]['rssi']),2);
        $packetSnrAverages["{$freq}"] =  number_format(getMean($packetDataByFrequency["{$freq}"]['snr']),2);
    }

    foreach ($witnessDataByFrequency as $freq => $rssifreq) {
        $witnessRssiAverages["{$freq}"] = number_format(getMean($witnessDataByFrequency["{$freq}"]['rssi']) ,2);
        $witnessRssiMins["{$freq}"] = number_format(min($witnessDataByFrequency["{$freq}"]['rssi']) ,2);
        $witnessSnrsAverages["{$freq}"] =  number_format(getMean($witnessDataByFrequency["{$freq}"]['snr']),2);
    }

    $freqs = array_keys($packetDataByFrequency);
    sort($freqs);

    $totalPacketsPerHour = number_format(round($totalPackets / $intervalInHours,2),2,".","");
    $totalWitnessesPerHour = number_format(round($totalWitnesses / $intervalInHours,2), 2,".","");
    $totalBeaconsPerDay = number_format(round($totalBeacons / $intervalInDays,2), 2,".","");

    $totalPacketsPerHour = str_pad("($totalPacketsPerHour",9, " ", STR_PAD_LEFT);;
    $totalWitnessesPerHour = str_pad("($totalWitnessesPerHour",9, " ", STR_PAD_LEFT);;
    $totalBeaconsPerDay = str_pad("($totalBeaconsPerDay",9, " ", STR_PAD_LEFT);;

    $totalWitnesses = str_pad($totalWitnesses,7, " ", STR_PAD_LEFT);
    $totalBeacons = str_pad($totalBeacons,7, " ", STR_PAD_LEFT);
    $totalPackets = str_pad($totalPackets,7, " ", STR_PAD_LEFT);
    $lowestPacketRssi = str_pad($lowestPacketRssi,7," ",STR_PAD_LEFT);
    $lowestWitnessRssi = str_pad($lowestWitnessRssi,7," ",STR_PAD_LEFT);
    $intervalInHoursStr = round($intervalInHours,1);

    $output = '<br><br><p><br><h2 style="color:#AED6F1;">General Overview</h2></p><br>';
    $output.='<table border="1" style="width: 100%; height: 100%">';
    $output.= "
        <tr border='1' align='left' style='color:#FCF3CF ;' >
        <th style='width:50%'> Description </th>
        <th align='left'> Value </th>
        </tr>";
    $output.="
        <tr border='1'>
            <td> First Packet </td>
            <td> {$startTime->format("d-m-Y H:i:s")} </td>
        </tr>";
    $output.="
        <tr border='1'>
            <td> Last Packet </td>
            <td> {$endTime->format("d-m-Y H:i:s")} ({$intervalInHoursStr} hours) </td>
        </tr>";
    $output.="
        <tr border='1'>
            <td> Total Witnesses </td>
            <td> {$totalWitnesses} {$totalWitnessesPerHour}/hour) </td>
        </tr>";
    $output.="
        <tr border='1'>
            <td> Total Packets </td>
            <td> {$totalPackets} {$totalPacketsPerHour}/hour) </td>
        </tr>";
    $output.="
        <tr border='1'>
            <td> Total Beacons </td>
            <td> {$totalBeacons} {$totalBeaconsPerDay}/day) </td>
        </tr>";
    $output.="
        <tr border='1'>
            <td> Lowest Witness RSSI </td>
            <td> {$lowestWitnessRssi} dBm </td>
        </tr>";
    $output.="
        <tr border='1'>
            <td> Lowest Packet RSSI </td>
            <td> {$lowestPacketRssi} dBm </td>
        </tr>";
    $output.= "</table>";

    $output.= '<br><p><br><h2 style="color:#AED6F1;">Packets Statistics</h2></p>';
    $output.='<table border="1" style="width: 100%; height: 100%">';
    $output.= "
        <tr border='1' align='left' style='color:#FCF3CF ;' >
        <th></th>
        <th></th>
        <th> Witnesses </th>
        <th></th>
        <th></th>
        <th></th>
        <th> All Packets </th>
        <th></th>
        <th></th>
        </tr>";
    $output.= "
        <tr border='1' align='left' style='color:#FCF3CF ;' >
        <td> Freq </td>
        <td> Num </td>
        <td> RSSI Avg </td>
        <td> RSSI Min </td>
        <td> SNR </td>
        <td> Num </td>
        <td> RSSI Avg </td>
        <td> RSSI Min </td>
        <td> SNR </td>
        </tr>";

    foreach ($freqs as $freq) {
        $numberOfWitnesses = count($witnessDataByFrequency[$freq]['rssi']);
        $witnessRssi = $witnessRssiAverages["{$freq}"];
        $witnessSnr = $witnessSnrsAverages["{$freq}"];
        $witnessRssiMin = $witnessRssiMins["{$freq}"];

        $numberOfPackets = count($packetDataByFrequency[$freq]['rssi']);
        $packetRssi = $packetRssiAverages["{$freq}"];
        $packetSnr = $packetSnrAverages["{$freq}"];
        $packetRssiMin = $packetRssiMins["{$freq}"];

        $output.= "
            <tr border='1' align='left'>
            <td> $freq </td>
            <td> $numberOfWitnesses </td>
            <td> $witnessRssi </td>
            <td> $witnessRssiMin </td>
            <td> $witnessSnr </td>
            <td> $numberOfPackets </td>
            <td> $packetRssi </td>
            <td> $packetRssiMin </td>
            <td> $packetSnr </td>
            </tr>";
    };
    $output.= "</table>";

    echo $output;
}


/**
 * @param $packets
 * @param $includeDataPackets
 * @param $showPayloadData
 * @return string
 */
function generateList($packets, $includeDataPackets = false, $showPayloadData = false) {

    if (empty($packets)) {
        return;
    }

    $systemDate = new DateTime();
    $utc = new DateTimeZone( 'UTC' );

    $dataFieldName = ($showPayloadData)?"Data":"Hash";

    $output = '<br><p><br><h2 style="color:#AED6F1;">Witnesses List</h2></p>';
    $output.= '<br><table border="1" style="width: 100%; height: 100%">';
    $output.="
            <tr style='color:#FCF3CF ;'>
            <th align='left'>Date</th>
            <th align='left'>Freq</th>
            <th align='left'>RSSI</th>
            <th align='left'>SNR</th>
            <th align='left'>Noise</th>
            <th align='left'>Type</th>
            <th align='left'>Datarate</th>
            <th align='left'>{$dataFieldName}</th>
            </tr>";

    foreach (array_reverse($packets) as $packet){
        if (($packet['type']=="tx data" || $packet['type']=="rx data") && !$includeDataPackets){
            continue;
        }

        $datetime = DateTime::createFromFormat('Y-m-d H:i:s',$packet['datetime'], $utc);
        $datetime->setTimezone($systemDate->getTimezone());

        $rssi = $packet['rssi'];

        if ($packet['type']=="witness"||$packet['type']=="rx data"){
            $noise = number_format((float)($packet['rssi'] - $packet['snr']));
        } else {
            $noise = "";
        }

        $snrStr = $packet['snr'];
        $noiseStr = $noise;
        $type = $packet['type'];
        $datarate = $packet['datarate'];

        if ($showPayloadData) {
            $dataField = $packet['data'];
        } else {
            $dataField = $packet['hash'];
        }

        $datetimeStr = $datetime->format("d-m-Y H:i:s");
        $output.="
            <tr border='1' align='left' style='font-size: 10px;' >
            <td> {$datetimeStr} </td>
            <td> {$packet['freq']} </td>
            <td> {$rssi} </td>
            <td> {$snrStr} </td>
            <td> {$noiseStr} </td>
            <td> {$type} </td>
            <td> {$datarate} </td>
            <td> {$dataField} </td>
            </tr>";
    }
    $output.="</table>";
    return $output;
}


/**
 * @param $packets
 * @param $includeDataPackets
 * @param $showPayloadData
 * @return string
 */
function generateCSV($packets, $filename = false, $includeDataPackets = false, $showPayloadData = false) {

    $columns = ['Date','Freq','RSSI','SNR','Noise','Type','Hash'];
    $data = array2csv($columns);
    foreach ($packets as $packet){
        if (($packet['type']=="tx data" || $packet['type']=="rx data") && !$includeDataPackets){
            continue;
        }

        if (!empty($packet['snr'])){
            $noise = number_format((float) ($packet['rssi'] - $packet['snr']),1);
        } else {
            $noise = "";
        }

        if ($showPayloadData) {
            $dataField = $packet['data'];
        } else {
            $dataField = @str_pad($packet['hash'], 44, " ", STR_PAD_RIGHT);
        }

        $data.= @array2csv([
                $packet['datetime'], $packet['freq'], $packet['rssi'], $packet['snr'], $noise, $packet['type'], $packet['datarate'], $dataField]
        );
    }

    if ($filename) {
        $data = "SEP=," . PHP_EOL . $data;
        file_put_contents($filename,$data);
        return "Data saved to $filename\n";
    }

    return $data;
}


/**
 * @param $packets
 * @param $includeDataPackets
 * @return string
 */
function generateHistogramData($packets, $includeDataPackets = false) {

    $systemDate = new DateTime();
    $utc = new DateTimeZone( 'UTC' );
    $histogram=[];

    foreach ($packets as $packet){
        if (($packet['type']=="tx data" || $packet['type']=="rx data") && !$includeDataPackets){
            continue;
        }

        $datetime = DateTime::createFromFormat('Y-m-d H:i:s',$packet['datetime'], $utc);
        $datetime->setTimezone($systemDate->getTimezone());

        $hour = (int) ($datetime->getTimestamp()/3600)*3600;
        $datetime->setTimestamp($hour);
        $hour = $datetime->format("d-m-Y H:i");
        //echo $hour . "\n";
        $histogram[$hour] = @$histogram[$hour] + 1;

    }
    return $histogram;
}

/**
 * @param $packets
 * @param $includeDataPackets
 * @return string
 */
function generateHistogramASCIIChart($histogramData)
{

    $cols = exec("tput cols") - 22;

    $output = "";

    $maxValue = max($histogramData);

    foreach ($histogramData as $date => $number){
        $output.= "$date ";
        for ($i=0; $i < $number/$maxValue*$cols; $i++) {
            $output.= "■";
        }
        $output.= " $number" . PHP_EOL;
    }

    return $output;
}

/**
 * @param $packets
 * @param $includeDataPackets
 * @return string
 */
function generateCSVHistogram($histogramData, $filename = false) {

    $columns = ['Date', 'Items'];

    $data = array2csv($columns);
    foreach ($histogramData as $date => $number){
        $data.= @array2csv([$date,$number]);
    }

    if ($filename) {
        $data = "SEP=," . PHP_EOL . $data;
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

function getMedian($arr) {
    sort($arr);
    $count = count($arr);
    $middleval = floor(($count-1)/2);
    if ($count % 2) {
        $median = $arr[$middleval];
    } else {
        $low = $arr[$middleval];
        $high = $arr[$middleval+1];
        $median = (($low+$high)/2);
    }
    return $median;
}

function getMean($arr) {
    $count = count($arr);
    return array_sum($arr)/$count;
}

function base64url_encode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}
