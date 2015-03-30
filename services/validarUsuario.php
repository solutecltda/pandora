<?php
	extract( $_REQUEST );
        require_once '../includes/config.php';
	$qu = pg_query($dbconn, "SELECT * FROM usuarios where bloqueado = false AND usuario='".$usuario."' LIMIT 1;");
        if( $qu )
          {
          // Obtener el número de filas:
            if( pg_num_rows($qu) > 0 )
            {
                 $obj = pg_fetch_object($qu);
          
                 if( trim($obj->clave) == trim($clave_ingresada) ){
                     $result = true  ;
                     //asdfasd 
                     echo "true";
                 } else { $result=false;echo "false"; }
                 
                 }
          }  else {pg_free_result($qu);}        
	pg_close($dbconn);
?>