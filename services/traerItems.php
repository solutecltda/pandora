<?php 
/*
#######################################
Ejeuta codigo
#######################################
*/
    //$db = pg_connect('host=192.168.150.72 dbname=solucon user=postgres password=postgres');

    require_once '../includes/config.php';
    extract($_REQUEST);

    $consul = "SELECT * FROM inventari_mv10 order by id desc OFFSET ".$offset." LIMIT ".$limit;
    $qu = pg_query ( $consul ) or die( "Error en la consulta SQL" );
    $regist = pg_num_rows( $qu );

    $itemsa = array(); 

    while( $obj = pg_fetch_object($qu) )
        {
         array_push($itemsa,$obj);
        }

    $result['reg'] = $itemsa;
    echo json_encode($result);

    pg_close();
?>