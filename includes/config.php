<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

	$dbconn = pg_connect("host=192.168.150.11 dbname=pdsinf_mxm_08 user=postgres")
				or die('No se ha podido conectar: ' . pg_last_error()) ;

