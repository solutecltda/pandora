<?php 
/*
#######################################
Ejeuta codigo
#######################################
*/
//$db = pg_connect('host=192.168.150.72 dbname=solucon user=postgres password=postgres');

require_once '../includes/config.php';

extract($_REQUEST);


$consul = "DELETE FROM sesiones_de_usuarios WHERE usuario = '".$usuario."'";

$qu = pg_query( $consul );

if ( $qu ) {
    echo "true";
    $result = true;
} else {
    $errmen = pg_last_error();
    echo "Error with query: ".$errmen;
    $result = false;
    exit();
}



pg_close();
?>