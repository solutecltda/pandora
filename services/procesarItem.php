<?php 
/*
#######################################
Ejeuta codigo
#######################################
*/
    //$db = pg_connect('host=192.168.150.72 dbname=solucon user=postgres password=postgres');
    require_once '../includes/config.php';
    extract($_REQUEST);

    $codigo = pg_escape_string( $_GET['codigo'] );

    $consul = "INSERT INTO inventari_mv10 ( id_parent, gondola, cara, consecutivo, ean, cantidad ) VALUES ( 0, '$gondola', '$cara', 0, '$codigo', '$cantidad' )";
    $qu = pg_query( $consul );
        if ( !$qu ) {
            $errmen = pg_last_error();
            echo "Error with query: ".$errmen;
            exit();
    }

    $qu = pg_query("SELECT COUNT(*) as cantidad FROM inventari_mv10 ;");
    if( $qu )
      {
      // Obtener el número de filas:
        if( pg_num_rows($qu) > 0 )
        {
             $obj = pg_fetch_object($qu);
             $result = $obj->cantidad;
             echo $obj->cantidad;
             }
      }  else {pg_free_result($qu); }





    pg_close();
?>