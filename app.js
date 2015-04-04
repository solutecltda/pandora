var app = angular.module('sampleApp', []);

var g_usuario = '';
var g_token = '';
var g_autenticado = '';
var g_cara = '';
var g_gondola = '';
var g_tipoinv = 1;
var g_nombreTipoinv = 'Barrido';

app.filter('range', function() {
      return function(input, total) {
        total = parseInt(total);
        for (var i=0; i<total; i++)
          input.push(i);
        return input;
      };
    } );


app.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/autenticacion', {
	templateUrl: 'autenticacion.html',
	controller: 'LoginController'
      }).
      when('/conteo', {
	templateUrl: 'conteo.html',
	controller: 'conteo'
      }).
      when('/barrido', {
	templateUrl: 'barrido.html',
	controller: 'barrido'
      }).
      when('/listado', {
	templateUrl: 'listado.html',
	controller: 'listado'        
      }).
      when('/transmitir', {
	templateUrl: 'transmitir.html',
	controller: 'transmitirController'        
      }).
      when('/configuracion', {
	templateUrl: 'configuracion.html',
	controller: 'configuracion'
      }).
      when('/consultarProveedor', {
	templateUrl: 'consultarProveedor.html',
	controller: 'ConsultarProveedorController'
      }).
      otherwise({
	redirectTo: '/autenticacion'
      });
}]);

app.controller('ConsultarProveedorController',['$scope','$http',function($scope,$http){
        
        
        $http.get('services/validarSesion.php?usuario='+g_usuario)
                .success(
                    function(data){
                        console.log('success ' + data);
                        if(data == 'false'){
                            location.href='#/autenticacion';} else {
                            return true;};
                        });
                        
        $scope.consultar = function(ean){
            //window.alert('hola mundo');
            // hacer la consulta
            // mostrar los proveedores en la pantalla
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

app.service('validarSesion',function($http) {
      
});

app.controller('conteo',['$scope','$http',function($scope,$http){
        
        
        $http.get('services/validarSesion.php?usuario='+g_usuario)
                .success(
                    function(data){
                        console.log('success ' + data);
                        if(data == 'false'){
                            location.href='#/autenticacion';} else {
                            return true;};
                        });
	
        
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

app.controller('barrido',['$scope','$http',function($scope,$http){
        
        
        $http.get('services/validarSesion.php?usuario='+g_usuario)
                .success(
                    function(data){
                        console.log('success ' + data);
                        if(data == 'false'){
                            location.href='#/autenticacion';} else {
                            return true;};
                        });
	
        
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


app.controller('listado',['$scope','$http', function($scope,$http){	
    
        $http.get('services/validarSesion.php?usuario='+g_usuario)
                .success(
                    function(data){
                        console.log('success ' + data);
                        if(data == 'false'){
                            location.href='#/autenticacion';} else {
                            return true;};
                        });

    	
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


app.controller('configuracion', function($scope,$http) {

    $http.get('services/validarUsuario.php?usuario='+g_usuario).
            success( 
            function(data){
                console.log(data.usuario);
        
    });
    
    
    $http.get('services/validarSesion.php?usuario='+g_usuario)
                .success(
                    function(data){
                        console.log('success ' + data);
                        if(data == 'false'){
                            location.href='#/autenticacion';} else {
                            return true;};
                        });

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

});

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

app.controller('transmitirController', function($scope,$http) {

        $http.get('services/validarSesion.php?usuario='+g_usuario)
                        .success(
                            function(data){
                                console.log('success ' + data);
                                if(data == 'false'){
                                    location.href='#/autenticacion';} else {
                                    return true;};
                                });


        $scope.nombreTipoinv = g_nombreTipoinv;

        $scope.transmitir = function(){
            window.alert('EN TRANSMISION ...');
            
            $http.get('services/transmitir.php?usuario='+g_usuario+'&gondola='+g_gondola+'&cara='+g_cara).success(
                    function(data){
                        console.log(data);
                    });
            
        };

    } );