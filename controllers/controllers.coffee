angular.module("site")
.run ($rootScope, localStorageService, SessionControl,$location) ->
	protocol = $location.protocol()
	host = $location.host()
	port = $location.port()
	$rootScope.token = SessionControl.get('app_token')
	$rootScope.authorized = SessionControl.signed_in('app_token')
	$rootScope.domain = protocol+'://'+host+':'+port
.controller("LandingCtrl",($rootScope,$scope,$resource,$location)->
			Catalogo = $resource($rootScope.domain+"/api/v1/catalogos/:id",{id:"@id"})
			New = $resource($rootScope.domain+"/api/v1/news/:id",{id:"@id"})
			Galeria = $resource($rootScope.domain+"/api/v1/galeries/:id",{id:"@id"})
			$scope.catalogos = Catalogo.query()
			$scope.news = New.query()
			$scope.galerias = Galeria.query()
			console.log $scope.galerias
		)
.controller("MenuCtrl",($scope,$resource,$location,$http,localStorageService,$rootScope)->
		Menu = $resource($rootScope.domain+"/api/v1/menus/:id",{id:"@id"})
		$scope.menus = Menu.query()
		$scope.logout = ()->
			$http.delete($rootScope.domain+'/api/v1/session').success((data) ->
				localStorageService.remove 'app_token', $rootScope.authorized
				window.location.href = $rootScope.domain
			).error (error) ->
				console.log error
	)
.controller("CarouselCtrl",($rootScope,$scope,$resource,$location)->
		Slider = $resource($rootScope.domain+"/api/v1/galeries/:id",{id:"@id"})
		$scope.sliders = Slider.query()
	)
.controller("CatalogoCtrl",($rootScope,$scope,$resource,$location)->
		Catalogo = $resource($rootScope.domain+"/api/v1/catalogos/:id",{id:"@id"})
		$scope.catalogos = Catalogo.query()
	)
.controller("CatalogoShowCtrl",($rootScope,$scope,$resource,$location,$routeParams,SessionControl)->
		Catalogo = $resource($rootScope.domain+"/api/v1/catalogos/:id",{id:"@id"})
		$scope.catalogo = Catalogo.get({id: $routeParams.id})
		$scope.change = ()->
			modelo = $("#modelo").text()
			color = $("#color").text()
			material = $("#material").text()
			size = $("#size").text()
			$('#modelo').replaceWith '<input type="text" ng-model="catalogo.modelo" value=\'' + modelo + '\' />'
			$('#color').replaceWith '<input type="text" ng-model="catalogo.color" value=\'' + color + '\' />'
			$('#material').replaceWith '<input type="text" ng-model="catalogo.material" value=\'' + material + '\' />'
			$('#size').replaceWith '<input type="text" ng-model="catalogo.sizes" value=\'' + size + '\' />'
			$('#edit_catalogo').replaceWith '<a class="waves-effect waves-light btn ng-click="save(file)"><i class="material-icons left">save</i>Guardar</a>'
			$("#panel" ).prepend("<a id='cancel_catalogo' class='btn rigth' href='' ng-click='save(file)'>Cancelar</a>")
			$("#file").prepend('<input type="file" ngf-select ng-model="picFile" name="file"    
             accept="image/*" ngf-max-size="2MB" required
             ngf-model-invalid="errorFile">')
			return false
		$scope.save = (file) ->
			console.log "click"

	)
.controller("PartnersController",()->
	)
.controller("BikeCtrl",()->
	)
.controller("DogmaCtrl",()->
	)
.controller 'LoginCtrl', [
  '$rootScope'
  '$scope'
  '$http'
  'localStorageService'
  '$location'
  ($rootScope,$scope, $http, localStorageService, $location) ->
    $scope.auth = ->
      $http.post($rootScope.domain+'/api/v1/sessions', user:
        email: $scope.loginForm.email
        password: $scope.loginForm.password).success((data) ->
        localStorageService.set 'app_token', data.token
        window.location.href = $rootScope.domain;
      ).error (error) ->
        console.log error
]
.controller("CpanelCtrl",($http,$rootScope,$scope,$resource,$location,$timeout,localStorageService,Upload)->
	if $rootScope.authorized==false
		$location.path("/")
	$scope.$on '$viewContentLoaded', (event) ->
		$ ->
			$('select').material_select();
			$(document).on 'click', '.modal-trigger', ->
				$('.modal-trigger').leanModal();
		return
	Catalogo = $resource($rootScope.domain+"/api/v1/catalogos/:id?token=:token",{id:"@id"},{update:{method:"PUT"}})
	New = $resource $rootScope.domain + '/api/v1/news/:id?token=:token', {id:'@id'}, {update:{method:"PUT"}}
	Menu = $resource($rootScope.domain+"/api/v1/menus/:id?token=:token",{id:"@id"},{update:{method:"PUT"}})
	$scope.catalogos = Catalogo.query()
	$scope.news = New.query()
	$scope.menus = Menu.query()
	$scope.catalogo = (file) ->
		file.upload = Upload.upload(
			url: $rootScope.domain+'/api/v1/catalogos?token='+$rootScope.token
			data: catalogo:
				marca: $scope.catalogo.marca
				modelo: $scope.catalogo.modelo
				tipo: $scope.catalogo.tipo
				imagen: file)
		file.upload.then ((response) ->
			$timeout ->
				file.result = response.data
				Materialize.toast('Sus datos fueron guardados!', 4000)
				$scope.catalogo = {
					'marca'     : ''
					'modelo'    : ''
					'picFile'	: ''
					'tipo'		: ''
				}
			), ((response) ->
				if response.status > 0
					$scope.errorMsg = response.status + ': ' + response.data
			), (evt) ->
				file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
	$scope.removeCatalogo = (id)->
		Catalogo.delete({id,"token":$rootScope.token}).$promise.then ((data) ->
			Materialize.toast(data.messages, 4000)
			$scope.catalogos = $scope.catalogos.filter (element)->
				return element.id != id
		), (response) ->
			Materialize.toast(response.data.errors, 4000)
	$scope.noticia = (file) ->
		file.upload = Upload.upload(
			url: $rootScope.domain+'/api/v1/news?token='+$rootScope.token
			data: new:
				title: $scope.new.title
				path: $scope.new.path
				cover: file)
		file.upload.then ((response) ->
			$timeout ->
				file.result = response.data
				Materialize.toast("Sus datos fueron guardados!", 4000)
				$scope.new = {
					'title'	:	''
					'path'	:	''
					'picFile'	: ''
				}
		), ((response) ->
			if response.status > 0
				$scope.errorMsg = response.status + ': ' + response.data
		), (evt) ->
			file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
	$scope.removeNew = (id)->
		New.delete({id,"token":$rootScope.token}).$promise.then ((data) ->
			Materialize.toast(data.messages, 4000)
			$scope.news = $scope.news.filter (element)->
				return element.id != id
		), (response) ->
			Materialize.toast(response.data.errors, 4000)
	$scope.navs = ()->
		$http.post($rootScope.domain+'/api/v1/menus?token='+$rootScope.token, menu:
			name: $scope.menu.name
			path: $scope.menu.path).success((data) ->
				Materialize.toast('Sus datos fueron guardados!', 4000)
		).error (error) ->
			console.log error
	$scope.removeNav = (id)->
		Menu.delete({id,"token":$rootScope.token}).$promise.then ((data) ->
			Materialize.toast(data.messages, 4000)
			$scope.menus = $scope.menus.filter (element)->
				return element.id != id
		), (response) ->
			Materialize.toast(response.data.errors, 4000)
	$scope.get_catalogo = (catalogo)->
		$scope.bici = catalogo
	$scope.catalogo_edit = (file)->
		$('.modal-trigger').leanModal();
		if file == undefined
			Catalogo.update({id:$scope.noticia.id,"token":$rootScope.token},{catalogo:{
					marca: $scope.bici.marca
					modelo: $scope.bici.modelo
					tipo: $scope.bici.tipo
				}}).$promise.then ((data) ->
					Materialize.toast("Datos actualizados!", 4000)
			), (response) ->
				Materialize.toast(response.data.errors, 4000)
		else
			file.upload = Upload.upload(
				url: $rootScope.domain+'/api/v1/catalogos/'+$scope.bici.id+'?token='+$rootScope.token
				method: 'PUT'
				data: catalogo:
					marca: $scope.bici.marca
					modelo: $scope.bici.modelo
					tipo: $scope.bici.tipo
					imagen: file)
			file.upload.then ((response) ->
				$timeout ->
					file.result = response.data
					Materialize.toast('Sus datos fueron guardados!', 4000)
				), ((response) ->
					if response.status > 0
						$scope.errorMsg = response.status + ': ' + response.data
				), (evt) ->
					file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
	$scope.get_noticia = (noticia)->
		$scope.noticia = noticia
	$scope.noticia_edit = (file)->
		if file == undefined
			New.update({id:$scope.noticia.id,"token":$rootScope.token},{
					new:
						title:$scope.noticia.title
						path:$scope.noticia.path
				}).$promise.then ((data) ->
					Materialize.toast("Datos actualizados!", 4000)
			), (response) ->
				Materialize.toast(response.data.errors, 4000)
		else
			file.upload = Upload.upload(
				url: $rootScope.domain+'/api/v1/news/'+$scope.noticia.id+'?token='+$rootScope.token
				method: 'PUT'
				data: new:
					title: $scope.noticia.title
					path: $scope.noticia.path
					cover: file)
			file.upload.then ((response) ->
				$timeout ->
					file.result = response.data
					Materialize.toast('Sus datos fueron guardados!', 4000)
				), ((response) ->
					if response.status > 0
						$scope.errorMsg = response.status + ': ' + response.data
				), (evt) ->
					file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
	$scope.get_menu = (menu)->
		$scope.nav = menu
	$scope.menu_edit = ()->
		Menu.update({id:$scope.nav.id,"token":$rootScope.token},{
					menu:
						name:$scope.nav.name
						path:$scope.noticia.path
				}).$promise.then ((data) ->
					Materialize.toast("Datos actualizados!", 4000)
			), (response) ->
				Materialize.toast(response.data.errors, 4000)
)
.factory("SessionControl",(localStorageService)->
		{
			get: (key) ->
				localStorageService.get key
			set: (key,value)->
				localStorageService.set key, value
			unset: (key)->
				localStorageService.remove key
			signed_in: (key)->
				if localStorageService.get(key) == null
					return false
				else
					return true
		}
)
.directive("modal",()->
		restrict: 'A'
		link: (scope, element, attrs) ->
			$('.modal-trigger').leanModal();
			return
	)
