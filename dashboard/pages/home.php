<?php
$load = sys_getloadavg();
$stats = @file_get_contents("/proc/meminfo");

$stats = str_replace(array("\r\n", "\n\r", "\r"), "\n", $stats);
$stats = explode("\n", $stats);

$tmpMemTotal = explode(":", $stats[0]);
$tmpMemTotal = trim(str_replace('kB', '', $tmpMemTotal[1]));

$tmpMemFree = explode(":", $stats[2]);
$tmpMemFree = trim(str_replace('kB', '', $tmpMemFree[1]));

$tmpMemUsed = $tmpMemTotal - $tmpMemFree;

$info['MemTotal'] = round(($tmpMemTotal / 1024) / 1024, 1)."GB";
$info['MemUsed'] = round(($tmpMemUsed / 1024) / 1024, 1)."GB";
$info['MemUsage'] = round(($tmpMemUsed / $tmpMemTotal) * 100, 2)."%";

$raw = array("eth0", "wlan0");
$pretty = array("LAN", "WLAN");

$info['IP'] = str_replace($raw, $pretty, trim(file_get_contents("/var/dashboard/statuses/local-ip")));
$info['ExternalIP'] = trim(file_get_contents("/var/dashboard/statuses/external-ip"));
$info['CPU'] = $load[0];

$pf = trim(file_get_contents("/var/dashboard/statuses/packet-forwarder"));
$info['BT'] = trim(ucfirst(file_get_contents("/var/dashboard/statuses/bt")));
$info['Miner'] = trim(file_get_contents("/var/dashboard/statuses/miner"));
$info['Temp'] = trim(file_get_contents("/var/dashboard/statuses/temp"));
$info['WiFi'] = trim(file_get_contents("/var/dashboard/statuses/wifi"));
$info['AutoMaintain'] = trim(file_get_contents("/var/dashboard/services/auto-maintain"));
$info['AutoUpdate'] = trim(file_get_contents("/var/dashboard/services/auto-update"));
$info['Uptime'] = str_replace("up ", "", shell_exec('uptime -p'));
$info['Timezone'] = trim(file_get_contents("/etc/timezone"));
$info['PantherXVer'] = trim(file_get_contents("/var/dashboard/statuses/pantherx_ver"));

if ($info['PantherXVer'] == 'X1')
{
	$diskfree = disk_free_space("/opt/miner_data") / 1073741824;
	$disktotal = disk_total_space("/opt/miner_data") / 1073741824;
}

if ($info['PantherXVer'] == 'X2')
{
	$diskfree = disk_free_space("/opt/panther-x2/miner_data") / 1073741824;
	$disktotal = disk_total_space("/opt/panther-x2/miner_data") / 1073741824;
}

$diskused = $disktotal - $diskfree;
$info['DiskUsage'] = round($diskused/$disktotal*100, 2)."%";

if($pf > 0)
{
	$info['PF'] = $pf;
}
else
{
	$info['PF'] = 'Disabled';
}
?>
<h1>Panther <?php echo $info['PantherXVer']; ?> Miner Dashboard</h1>

<div id="miner_info">
<h2>Miner Information</h2>
<ul>
<li>IP: <strong><?php echo $info['IP'].' / '.$info['ExternalIP']; ?></strong></li>
<li>CPU: <?php echo $info['CPU']; ?></li>
<li>Mem: <?php echo $info['MemUsed']." / ".$info['MemTotal']." - ".$info['MemUsage']; ?></li>
<li>Disk: <?php echo $info['DiskUsage']; ?></li>
<li>Temp: <?php echo $info['Temp']; ?></li>
<li>Uptime: <?php echo $info['Uptime']; ?></li>
<li>Timezone: <?php echo $info['Timezone']; ?></li>
</ul>
</div>

<div id="toggle_buttons">
<h2>Enable/disable Services</h2>
<ul>
<?php
if($info['BT'] == 'On')
{
echo '<li id="BT_status" class="enabled">';
echo '<a href="#" onclick="DisableService(\'BT\');" title="Bluetooth advertise enabled">';
echo '<span class="icon-bluetooth"></span>';
echo '</a>';
echo '</li>';
}
else
{
echo '<li id="BT_status" class="disabled">';
echo '<a href="#" onclick="EnableService(\'BT\');" title="BlueTooth advertise disabled">';
echo '<span class="icon-bluetooth_disabled"></span>';
echo '</a>';
echo '</li>';

}

if($info['PF'] != 'Disabled')
{
echo '<li id="PF_status" class="enabled">';
echo '<a href="#" onclick="DisableService(\'PF\');" title="Packet forwarder enabled: '.$info['PF'].'">';
echo '<span class="icon-play_arrow"></span>';
echo '</a>';
echo '</li>';
}
else
{
echo '<li id="PF_status" class="disabled">';
echo '<a href="#" onclick="EnableService(\'PF\');" title="Packet forwarder disabled">';
echo '<span class="icon-play_disabled"></span>';
echo '</a>';
echo '</li>';

}

if($info['Miner'] == 'true')
{
echo '<li id="Miner_status" class="enabled">';
echo '<a href="#" onclick="DisableService(\'miner\');" title="Miner enabled">';
echo '<span class="icon-zap"></span>';
echo '</a>';
echo '</li>';
}
else
{
echo '<li id="Miner_status" class="disabled">';
echo '<a href="#" onclick="EnableService(\'miner\');" title="Miner disabled">';
echo '<span class="icon-zap-off"></span>';
echo '</a>';
echo '</li>';

}

if($info['WiFi'] != '')
{
echo '<li id="WiFi_status" class="enabled">';
echo '<a href="#" onclick="DisableService(\'WiFi\');" title="WiFi enabled">';
echo '<span class="icon-wifi"></span>';
echo '</a>';
echo '</li>';
}
else
{
echo '<li id="WiFi_status" class="disabled">';
echo '<a href="#" onclick="EnableService(\'WiFi\');" title="WiFi disabled">';
echo '<span class="icon-wifi-off"></span>';
echo '</a>';
echo '</li>';

}

if($info['AutoMaintain'] == 'enabled')
{
echo '<li id="AutoMaintain_status" class="enabled">';
echo '<a href="#" onclick="DisableService(\'AutoMaintain\');" title="AutoMaintain enabled">';
echo '<span class="icon-wrench"></span>';
echo '</a>';
echo '</li>';
}
else
{
echo '<li id="AutoMaintain_status" class="disabled">';
echo '<a href="#" onclick="EnableService(\'AutoMaintain\');" title="AutoMaintain disabled">';
echo '<span class="icon-wrench"></span>';
echo '</a>';
echo '</li>';
}

if($info['AutoUpdate'] == 'enabled')
{
echo '<li id="AutoUpdate_status" class="enabled">';
echo '<a href="#" onclick="DisableService(\'AutoUpdate\');" title="AutoUpdate enabled">';
echo '<span class="icon-loop2"></span>';
echo '</a>';
echo '</li>';
}
else
{
echo '<li id="AutoUpdate_status" class="disabled">';
echo '<a href="#" onclick="EnableService(\'AutoUpdate\');" title="AutoUpdate disabled">';
echo '<span class="icon-loop2"></span>';
echo '</a>';
echo '</li>';
}


?>
</ul>
</div>
