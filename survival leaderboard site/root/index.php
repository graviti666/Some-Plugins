<!--
<html lang="en">
<meta charset="utf-8">

	full-team category site and main one index.php

	$wholeseconds = floor($row["time"]);
	$minutes = floor($wholeseconds / 60);
	$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
	$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
	$length = $minutes . ':' . $seconds;
	
	$player1 = $row["p1_name"];
	$player2 = $row["p2_name"];
	$player3 = $row["p3_name"];
	$player4 = $row["p4_name"];
	$sirate = $row["sirate"];
	$roundID = $row["id"];
	$date = $row["date"];
	
	<style>
		body {
		background-image: url("images/atrium_2.jpg");
		background-repeat: no-repeat;
		background-attachment: fixed;
		background-position: center;
		background-size: cover;
	}
	</style>
-->
<?php
include "connection.php";
?>

<?php
  $mall = array('images/atrium_1.jpg', 'images/atrium_2.jpg', 'images/atrium_3.jpg'); // array of filenames

  $i = rand(0, count($mall)-1); // generate random number size of the array
  $mallpic = "$mall[$i]"; // set variable equal to which random filename was chosen
  
  $motel = array('images/motel_1.jpg', 'images/motel_2.jpg');
  $i = rand(0, count($motel)-1);
  $motelpic = "$motel[$i]";
  
  $stad = array('images/stadiumgate_1.jpg', 'images/stadiumgate_2.jpg');
  $i = rand(0, count($stad)-1);
  $stadpic = "$stad[$i]";
  
  $conc = array('images/concert_1.jpg', 'images/concert_2.jpg');
  $i = rand(0, count($conc)-1);
  $concertpic = "$conc[$i]";
  
  $gator = array('images/gatorvillage_1.jpg', 'images/gatorvillage_2.jpg');
  $i = rand(0, count($gator)-1);
  $gatorpic = "$gator[$i]";
  
  $plant = array('images/plant_1.jpg', 'images/plant_2.jpg');
  $i = rand(0, count($plant)-1);
  $plantpic = "$plant[$i]";
  
  $burg = array('images/burger_1.jpg', 'images/burger_2.jpg');
  $i = rand(0, count($burg)-1);
  $burgerpic = "$burg[$i]";
  
  $sug = array('images/sugar_1.jpg', 'images/sugar_2.jpg');
  $i = rand(0, count($sug)-1);
  $sugarpic = "$sug[$i]";
  
  $bus = array('images/busdepot_1.jpg', 'images/busdepot_2.jpg');
  $i = rand(0, count($bus)-1);
  $buspic = "$bus[$i]";
  
  $bridg = array('images/bridge_1.jpg', 'images/bridge_2.jpg');
  $i = rand(0, count($bridg)-1);
  $bridgepic = "$bridg[$i]";
  
  $riv = array('images/riverbank_1.jpg', 'images/riverbank_2.jpg');
  $i = rand(0, count($riv)-1);
  $riverpic = "$riv[$i]";
  
  $bed = array('images/bedlam_1.jpg', 'images/bedlam_2.jpg');
  $i = rand(0, count($bed)-1);
  $bedlampic = "$bed[$i]";
  
  $portp = array('images/portp_1.jpg', 'images/portp_2.jpg');
  $i = rand(0, count($portp)-1);
  $portpassingpic = "$portp[$i]";
  
  $trein = array('images/traincar_1.jpg', 'images/traincar_2.jpg');
  $i = rand(0, count($trein)-1);
  $traincarpic = "$trein[$i]";
  
  $ports = array('images/ports_1.jpg', 'images/ports_2.jpg');
  $i = rand(0, count($ports)-1);
  $portsacpic = "$ports[$i]";
  
  $gen = array('images/genroom_1.jpg', 'images/genroom_2.jpg');
  $i = rand(0, count($gen)-1);
  $genroompic = "$gen[$i]";
  
  $roofy = array('images/rooftop_1.jpg', 'images/rooftop_2.jpg');
  $i = rand(0, count($roofy)-1);
  $roofpic = "$roofy[$i]";
?>
<!DOCTYPE html>
<html lang="en">
<html>
<head>
	<title>Survival Leaderboard</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="style.css">
	</style>
	
	<style>
		body {
		background-image: url("images/atrium_2.jpg");
		background-repeat: no-repeat;
		background-attachment: fixed;
		background-position: center;
		background-size: cover;
	}
	</style>
</head>

<style>
	h1{
		color: ivory;
	}
</style>

<body>

<br>

<div class="header">
	<h2>Survival Leaderboard</h2>
</div>

<!-- map selection dropdown menu -->
<ul>
  <li><a href="index.php?rule=4&map=atrium">Survival Records</a></li>
  <li><a href="classic.php?rule=4&map=atrium">Classic Survival Records</a></li>
  <div class="dropdown">
	<button class="dropbtn">Maps
		<i class="fa fa-caret-down"></i>
	</button>
	<div class="dropdown-content">
		<a href="index.php?map=atrium&rule">Mall</a>
		<a href="index.php?map=motel&rule">Motel</a>
		<a href="index.php?map=stadium&rule">Stadium Gate</a>
		<a href="index.php?map=concert&rule">Concert</a>
		<a href="index.php?map=gator&rule">Gator Village</a>
		<a href="index.php?map=plant&rule">Plantation</a>
		<a href="index.php?map=burger&rule">Burger Tank</a>
		<a href="index.php?map=sugar&rule">Sugar Mill</a>
		<a href="index.php?map=busdepot&rule">Bus Depot</a>
		<a href="index.php?map=bridge&rule">Bridge</a>
		<a href="index.php?map=river&rule">Riverbank</a>
		<a href="index.php?map=bedlam&rule">Bedlam</a>
		<a href="index.php?map=portp&rule">Port Passing</a>
		<a href="index.php?map=traincar&rule">Traincar</a>
		<a href="index.php?map=ports&rule">Port Sacrifice</a>
		<a href="index.php?map=generoom&rule">Generator Room</a>
		<a href="index.php?map=rooftop&rule">Rooftop</a>
	</div>
</ul>

<br>

<?php if(isset($_GET['map'])){
	$map = $_GET['map'];
}else {
	$map = "atrium";
}

if($map=='atrium') {
	?>
	<h1><b>Mall Atrium</b></h1>
	<?php
}
else if($map=='motel') {
	?>
	<h1><b>Motel</b></h1>
	<?php
}
else if($map=='stadium') {
	?>
	<h1><b>Stadium Gate</b></h1>
	<?php
}
else if($map=='concert') {
	?>
	<h1><b>Concert</b></h1>
	<?php
}
else if($map=='gator') {
	?>
	<h1><b>Gator Village</b></h1>
	<?php
}
else if($map=='plant') {
	?>
	<h1><b>Plantation</b></h1>
	<?php
}
else if($map=='burger') {
	?>
	<h1><b>Burger Tank</b></h1>
	<?php
}
else if($map=='sugar') {
	?>
	<h1><b>Sugar Mill</b></h1>
	<?php
}
else if($map=='busdepot') {
	?>
	<h1><b>Bus Depot</b></h1>
	<?php
}
else if($map=='bridge') {
	?>
	<h1><b>Bridge</b></h1>
	<?php
}
else if($map=='river') {
	?>
	<h1><b>Riverbank</b></h1>
	<?php
}
else if($map=='bedlam') {
	?>
	<h1><b>Bedlam</b></h1>
	<?php
}
else if($map=='portp') {
	?>
	<h1><b>Port Passing</b></h1>
	<?php
}
else if($map=='traincar') {
	?>
	<h1><b>Traincar</b></h1>
	<?php
}
else if($map=='ports') {
	?>
	<h1><b>Port Sacrifice</b></h1>
	<?php
}
else if($map=='generoom') {
	?>
	<h1><b>Generator Room</b></h1>
	<?php
}
else if($map=='rooftop') {
	?>
	<h1><b>Rooftop</b></h1>
	<?php
}
?>

<!-- category selectio menu -->
<ul>
	<?php
	if(isset($_GET['map'])) {
		$map = $_GET['map'];
	} else {
		$map = "atrium";
	}
	echo " 
	<li><a href='index.php?map=$map&rule=4'>full-team</a></li>
	<li><a href='index.php?map=$map&rule=3'>trio</a></li>
	<li><a href='index.php?map=$map&rule=2'>duo</a></li>
	<li><a href='index.php?map=$map&rule=1'>solo</a></li>
	";
	?>
</ul>

<script>
function getQueryVariable(variable)
{
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable){return pair[1];}
       }
       return(false);
}
</script>

<?php

if(isset($_GET['rule'])) {
	$rule = $_GET['rule'];
}
else 
{
	$rule = 4;
}

if(isset($_GET['map'])) {
	$map = $_GET['map'];
}
else 
{
	$map = "c1m4_atrium";
}

// dead center
if($map=='atrium'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $mallpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c1m4_atrium' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c1m4_atrium' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c1m4_atrium' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c1m4_atrium' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

// dark carnival
else if($map=='motel') {
	?>	
	<style type="text/css">
		body{
		background: url(<?php echo $motelpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m1_highway' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m1_highway' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m1_highway' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m1_highway' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='stadium') {
	?>	
	<style type="text/css">
		body{
		background: url(<?php echo $stadpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m4_barns' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m4_barns' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m4_barns' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m4_barns' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='concert'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $concertpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m5_concert' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m5_concert' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m5_concert' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c2m5_concert' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

// swamp fever
else if($map=='gator'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $gatorpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c3m1_plankcountry' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c3m1_plankcountry' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c3m1_plankcountry' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c3m1_plankcountry' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='plant'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $plantpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c3m4_plantation' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c3m4_plantation' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c3m4_plantation' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c3m4_plantation' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

// hard rain
else if($map=='burger'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $burgerpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c4m1_milltown_a' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c4m1_milltown_a' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c4m1_milltown_a' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c4m1_milltown_a' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='sugar'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $sugarpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c4m2_sugarmill_a' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c4m2_sugarmill_a' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c4m2_sugarmill_a' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c4m2_sugarmill_a' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

// parish
else if($map=='busdepot'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $buspic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c5m2_park' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c5m2_park' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c5m2_park' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c5m2_park' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='bridge'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $bridgepic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c5m5_brige' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c5m5_brige' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c5m5_brige' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c5m5_brige' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

// passing
else if($map=='river'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $riverpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m1_riverbank' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m1_riverbank' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m1_riverbank' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m1_riverbank' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='bedlam'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $bedlampic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m2_bedlam' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m2_bedlam' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m2_bedlam' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m2_bedlam' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='portp'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $portpassingpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m3_port' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m3_port' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m3_port' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c6m3_port' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

// sacrifice
else if($map=='traincar'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $traincarpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c7m1_docks' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c7m1_docks' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c7m1_docks' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c7m1_docks' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='ports'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $portsacpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c7m3_port' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c7m3_port' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c7m3_port' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c7m3_port' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

// no mercy
else if($map=='generoom'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $genroompic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c8m2_subway' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c8m2_subway' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c8m2_subway' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c8m2_subway' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

else if($map=='rooftop'){
	?>
	<style type="text/css">
		body{
		background: url(<?php echo $roofpic; ?>) no-repeat;
		background-size: cover;
		background-attachment: fixed;
	}
	</style>
	<?php
	if($rule==1){
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c8m5_rooftop' AND category='solo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==2) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c8m5_rooftop' AND category='duo' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==3) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c8m5_rooftop' AND category='trio' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
	else if($rule==4) {
		$sql = "SELECT * FROM survival_leaderboard WHERE map='c8m5_rooftop' AND category='full-team' ORDER BY time DESC LIMIT 20";
		$result = $mysqli->query($sql);
		
		$index = 0;
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				$index++;
			
				// format the time column properly
				$wholeseconds = floor($row["time"]);
				$minutes = floor($wholeseconds / 60);
				$seconds = str_pad(($wholeseconds - $minutes * 60), 2, "0", STR_PAD_LEFT);
				$millisec = str_pad(floor(1000 * ($row["time"] - $wholeseconds)), 3, "0", STR_PAD_LEFT);
				$length = $minutes . ':' . $seconds;
		
				$totalTime = " " . $length . "." . $millisec;
				$roundID = $row["id"];
				$date = $row["date"];
				$sirate = $row["sirate"];
				$player1 = $row["p1_name"];
				$player2 = $row["p2_name"];
				$player3 = $row["p3_name"];
				$player4 = $row["p4_name"];
		
				// Player steam ID's
				$player1ID = $row["p1_steam64"];
				$player2ID = $row["p2_steam64"];
				$player3ID = $row["p3_steam64"];
				$player4ID = $row["p4_steam64"];
			
				echo "
				<button class='accordion'>#$index  $totalTime - $player1, $player2, $player3, $player4</button>
				<div class='panel'>
				<table id='roundinfo_table'>
					<tr>
						<th>Round ID</th>
						<th>Date</th>
						<th>SI/min</th>
					</tr>
					<tr>
						<td>$roundID</td>
						<td>$date</td>
						<td>$sirate</td>
					</tr>
					<tr>
						<th>Player(s)</th>
						<th>Steam64 ID</th>
						<th>Profile</th>
					</tr>
					<tr>
						<td>$player1</td>
						<td>$player1ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player1ID'>Link</td>
					</tr>
					<tr>
						<td>$player2</td>
						<td>$player2ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player2ID'>Link</td>
					</tr>
					<tr>
						<td>$player3</td>
						<td>$player3ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player3ID'>Link</td>
					</tr>
					<tr>
						<td>$player4</td>
						<td>$player4ID</td>
						<td><a href='https://www.steamcommunity.com/profiles/$player4ID'>Link</td>
					</tr>
					</table>
					</div>
					</button>
				";
			}
		}
	}
}

?>

<br><br><br><br><br><br>

<!-- Accordion script -->
<script>
var acc = document.getElementsByClassName("accordion");
var i;

for (i = 0; i < acc.length; i++) {
  acc[i].addEventListener("click", function() {
    this.classList.toggle("active");
    var panel = this.nextElementSibling;
    if (panel.style.display === "block") {
      panel.style.display = "none";
    } else {
      panel.style.display = "block";
    }
  });
}
</script>

</body>
</html>