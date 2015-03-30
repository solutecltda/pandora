<?php 
/*
#######################################
Ejeuta codigo
#######################################
*/
//$db = pg_connect('host=192.168.150.72 dbname=solucon user=postgres password=postgres');

    require_once '../includes/config.php';

    extract($_REQUEST);

    $token = sha1(uniqid($usuario, true));
    $sello_de_tiempo = time();

    $consul = "INSERT INTO sesiones_de_usuarios ( token,usuario,sello_de_tiempo ) VALUES ('$token', '$usuario', $sello_de_tiempo )";

    $qu = pg_query( $consul );

    if ( $qu ) {
        echo $token;
        $result = true;
    } else {
        $errmen = pg_last_error();
        echo "Error with query: ".$errmen;
        $result = false;
        exit();
    }



    pg_close();
?>