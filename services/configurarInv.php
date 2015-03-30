<?php 
/*
#######################################
Ejeuta codigo
#######################################
*/
// $db = pg_connect('host=192.168.150.72 dbname=solucon user=postgres password=postgres');
require_once '../includes/config.php';

extract($_REQUEST);

$consul = "select configurar_inv('".$usuario."',$cara,$gondola,'".$tipoinv."');";
$qu = pg_query( $consul );
    if ( !$qu ) {
	$errmen = pg_last_error();
	echo "Error with query: ".$errmen;
	exit();
}



pg_close();
?>