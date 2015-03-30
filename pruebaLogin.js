/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var app = angular.module('loginApp',[]);

app.controller('LoginController',function($scope,$http){
    window.alert('hola mundo');
 
    var userInfo;
 
    function login(userName, password) {
        var deferred = $q.defer();
 
    $http.post("services/login?usuario="+userName+"&password="+password).then(function(result) {
      userInfo = {
        accessToken: result.data.access_token,
        userName: result.data.userName
      };
      $window.sessionStorage["userInfo"] = JSON.stringify(userInfo);
      deferred.resolve(userInfo);
    }, function(error) {
      deferred.reject(error);
    });
 
    return deferred.promise;
  }
 
  return {
    login: login
    //getUserInfo: getUserInfo
  };
  
  $scope.validar = function(usuario,clave){
      
      obj = login(usuario,clave);
      window.alert(obj.login);
      
  }
  
  
  
});
