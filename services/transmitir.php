<?php 
/*
#######################################
Ejeuta codigo
#######################################
*/
require_once '../includes/config.php';

extract($_REQUEST);

$consul = "select pda_transmitir_inv('".$usuario."',$cara,$gondola);";
$qu = pg_query( $consul );
    if ( !$qu ) {
	$errmen = pg_last_error();
	echo "Error with query: ".$errmen;
	exit();
}



pg_close();
?>