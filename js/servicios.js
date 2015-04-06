/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var app = angular.module('app.services',[]);
    
app.factory('bbtServicios', ['$http', function($http) {
    var sdo = {
            autorizado : function() {
                var promise = $http({
                method: 'GET',
                url: './services/validarSesion.php?usuario='+g_usuario
                });
                promise.success(function(data, status, headers, conf) {
                return data;
            });
            return promise;
            }
    };
    return sdo;
}]);