<?php
	extract( $_REQUEST );

	//$dbconn = pg_connect("host=localhost dbname=solucon user=postgres") or die('No se ha podido conectar: ' . pg_last_error());		
        require_once '../includes/config.php';
	$qu = pg_query($dbconn, "SELECT COUNT(*) as cantidad FROM inventari_mv10 ;");
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
          
	pg_close($dbconn);
?>