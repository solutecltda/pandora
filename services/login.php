<?php
	extract( $_REQUEST );
        //$usuario = 'mauricio';
        //$clave_ingresada = 'toby';

	//$dbconn = pg_connect("host=localhost dbname=solucon user=postgres") or die('No se ha podido conectar: ' . pg_last_error());
        
        require_once '../includes/config.php';
        
	$qu = pg_query($dbconn, "SELECT * FROM usuarios where usuario='".$usuario."' LIMIT 1;");
        if( $qu )
          {
          // Obtener el número de filas:
            if( pg_num_rows($qu) > 0 )
            {
                 $obj = pg_fetch_object($qu);
                 if( trim($obj->clave) == trim($clave_ingresada) ){
                     $result = sha1(uniqid($usuario, true));
                     echo "true";
                 } else { $result=false;echo "false"; }
                 
                 }
          }  else {pg_free_result($qu);}        
	pg_close($dbconn);
?>

