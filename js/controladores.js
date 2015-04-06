/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var app = angular.module('app.controllers',[]);

app.controller('ConsultarProveedorController',['$scope','$http','autorizado',function($scope,$http,autorizado){

        console.log('Autorizado = '+autorizado.data );
        
        if(autorizado.data === 'false'){location.href='#/autenticacion';return false;};
                        
        $scope.consultar = function(ean){
            $scope.proveedor = 'El proveedor de '+$scope.ean + ' es ';
            $scope.ean = '';            
        };
	
}]);
    

app.controller('principal', function($scope,$http) {

        $scope.nombreTipoinv = g_nombreTipoinv;
        
        $scope.cerrarSesion = function(){
            $http.get('services/cerrarSesion.php?usuario='+g_usuario).success(function(data){
               console.log('session de usuario '+g_usuario+' cerrada con exito '); 
               location.href='#/autenticacion';
        } )};
        

});

app.controller('conteo',['$scope','$http','validarSesion','autorizado',function($scope,$http,validarSesion,autorizado){
        
        
        console.log('Autorizado = '+autorizado.data );
        
        if(autorizado.data === 'false'){location.href='#/autenticacion';return false;};
        
	$scope.message = 'CONTEO';
        
        $scope.conteoInicio = function(){ };

        $scope.contarItems = function(){
            $http.get('services/contarItems.php').success(function(data){
                console.log('registros = ',data);
                $scope.paginas = ( parseInt(data) / $scope.registrosPorPagina)+1;
                return parseInt(data);
            } );
        };
            

        $scope.procesarItem = function(){
            if($scope.codigo == null){window.alert('se require el codigo..');return false};

            //if(typeof $scope.cantidad === 'undefined'){$scope.cantidad = 0};
            $http.get('services/procesarItem.php?codigo='+$scope.codigo+'&cantidad='+$scope.cantidad+'&cara='+g_cara+'&gondola='+g_gondola)
                  .success(function(data){
                     console.log('se grabo registro con exito');
                     console.log(data);
                     $scope.numRecs = parseInt(data);
                  } );
            $scope.codigo = '';            
            
        };    
	
}]);

app.controller('barrido',['$scope','$http','autorizado',function($scope,$http,autorizado){
        
        
        console.log('Autorizado = '+autorizado.data );
        
        if(autorizado.data === 'false'){location.href='#/autenticacion';return false;};
	
        
	$scope.message = 'CONTEO';
        
        $scope.conteoInicio = function(){ };

        $scope.contarItems = function(){
            $http.get('services/contarItems.php').success(function(data){
                console.log('registros = ',data);
                $scope.paginas = ( parseInt(data) / $scope.registrosPorPagina)+1;
                return parseInt(data);
            } );
        };
            

        $scope.procesarItem = function(){
            if($scope.codigo == null){window.alert('se require el codigo..');return false};

            //if(typeof $scope.cantidad === 'undefined'){$scope.cantidad = 0};
            $http.get('services/procesarItem.php?codigo='+$scope.codigo+'&cantidad='+$scope.cantidad+'&cara='+g_cara+'&gondola='+g_gondola)
                  .success(function(data){
                     console.log('se grabo registro con exito');
                     console.log(data);
                     $scope.numRecs = parseInt(data);
                  } );
            $scope.codigo = '';            
            
        };    
	
}]);


app.controller('listado',['$scope','$http','autorizado', function($scope,$http,autorizado){	
    
        console.log('Autorizado = '+autorizado.data );
        
        if(autorizado.data === 'false'){location.href='#/autenticacion';return false;};

    	
        $scope.message = 'Descargando datos ...';
        $scope.registrosPorPagina = 7;
        
        $scope.setPagina = function(offset,limit){
           //window.alert('hello world');
           $http.get('services/traerItems.php?offset='+offset+'&limit='+limit)
                  .success(function(data){
                     $scope.items = data.reg;
                     console.log('trajeron los registros');
                     $scope.message = '';
                     console.log(data.reg);
                  });

        };
        
        $scope.mostrarInicio = function(){
           $scope.message = 'Procesando ...'; 
        };
        
        $scope.contarItems = function(){
            $http.get('services/contarItems.php').success(function(data){
                console.log('registros = ',data);
                $scope.paginas = ( parseInt(data) / $scope.registrosPorPagina)+1;
                return parseInt(data);
            });
            
        };

		
}] );


app.controller('configuracion',['$scope','$http','autorizado',function($scope,$http,autorizado) {

        console.log('Autorizado = '+autorizado.data );
        
        if(autorizado.data === 'false'){location.href='#/autenticacion';return false;};
    
    

	$scope.message = 'CONFIGURACION';
        $scope.cara    = g_cara;
        $scope.gondola = g_gondola;
        $scope.tipoinv = g_tipoinv;
        
        $scope.configurarInv = function(){
            $http.get('services/configurarInv.php?usuario='+g_usuario+'&gondola='+$scope.gondola+'&cara='+$scope.cara+'&tipoinv='+$scope.tipoinv).success(
                    function(data){
                        console.log(data);
                        g_cara = $scope.cara;
                        g_gondola = $scope.gondola;
                        g_tipoinv = $scope.tipoinv;
                        g_nombreTipoinv = (($scope.tipoinv == 1)?"Barrido":"Conteo");
                        console.log('nombreTipoinv = '+g_nombreTipoinv);
                        if($scope.tipoinv == 1){location.href='#/barrido';} else {location.href='#/conteo'; };
                        
                    });
                    
            
        };

}]);

app.controller('LoginController', function ($scope, $http) {
  
   //window.alert('estoy en loginController'); 
   $scope.login = function(usuario,clave){
            //window.alert('estoy en la funcion login');
            $http.get('services/login.php?usuario='+$scope.usuario+'&clave_ingresada='+$scope.clave).success(
                function(data){
                   console.log(' string : services/login.php?usuario='+$scope.usuario+'&clave_ingresada='+$scope.clave+'Resultado = '+data)
                   
                   if (data.trim() == 'true'){
                       g_usuario = $scope.usuario;                       
                       console.log(data);
                       $http.get('services/crearSesion.php?usuario='+g_usuario).success(function(data){
                           g_token = data;
                       });
                       
                       location.href='#/configuracion';
                   } else {
                       window.alert('Clave errada');
                       return false;
                   }
                   
                   
                   
                });

       
   }
  
});

app.controller('transmitirController','autorizado', function($scope,$http,autorizado) {

        console.log('Autorizado = '+autorizado.data );
        
        if(autorizado.data === 'false'){location.href='#/autenticacion';return false;};


        $scope.nombreTipoinv = g_nombreTipoinv;

        $scope.transmitir = function(){
            window.alert('EN TRANSMISION ...');
            
            $http.get('services/transmitir.php?usuario='+g_usuario+'&gondola='+g_gondola+'&cara='+g_cara).success(
                    function(data){
                        console.log(data);
                    });
            
        };

    } );