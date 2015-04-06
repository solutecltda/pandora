var app = angular.module('sampleApp', ['app.services','app.controllers']);

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
	controller: 'conteo',
        resolve : {
            autorizado : function(bbtServicios){
                return bbtServicios.autorizado();
            }
        }        
      }).
      when('/barrido', {
	templateUrl: 'barrido.html',
	controller: 'barrido',
        resolve : {
            autorizado : function(bbtServicios){
                return bbtServicios.autorizado();
            }
        }        
      }).
      when('/listado', {
	templateUrl: 'listado.html',
	controller: 'listado',
        resolve : {
            autorizado : function(bbtServicios){
                return bbtServicios.autorizado();
            }
        }                
      }).
      when('/transmitir', {
	templateUrl: 'transmitir.html',
	controller: 'transmitirController',
        resolve : {
            autorizado : function(bbtServicios){
                return bbtServicios.autorizado();
            }
        }                
      }).
      when('/configuracion', {
	templateUrl: 'configuracion.html',
	controller: 'configuracion',
        resolve : {
            autorizado : function(bbtServicios){
                return bbtServicios.autorizado();
            }
        }                
      }).
      when('/consultarProveedor', {
	templateUrl: 'consultarProveedor.html',
	controller: 'ConsultarProveedorController',
        resolve : {
            autorizado : function(bbtServicios){
                return bbtServicios.autorizado();
            }
        }                
      }).
      otherwise({
	redirectTo: '/autenticacion'
      });
}]);

