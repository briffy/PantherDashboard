<?php
$host_prot = array("mainnet-router.helium.io"=>"8080",
                   "entropy.iot.mainnet.helium.io"=>"7080",
                   "mainnet-pociot.helium.io"=>"9080",
                   "mainnet-config.helium.io"=>"6080");
function check_port($host, $port) {
      $connection = @fsockopen($host, $port);
      if (is_resource($connection)) {
        fclose($connection);
        return true;
      } else {
        return false;
      }
}

foreach($host_prot as $host => $port)
    if (check_port($host, $port)) {
      echo "$host:$port is open\n";
    } else {
      echo "$host:$port is closed\n";
    }
?>