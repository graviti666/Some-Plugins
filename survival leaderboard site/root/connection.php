<?php
/* Fill with the database login information */
$host = "";					//hostname
$username = "";				//username
$user_pass = "";			//password
$database_in_use = "";		// name for the database
$port = "3306";

/* We initiliaze the connection to our server */
$mysqli = new mysqli($host, $username, $user_pass, $database_in_use, $port);

/* Echo out if there was an error while connecting */
if ($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
}
?>