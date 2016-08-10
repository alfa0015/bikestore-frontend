angular.module("site")
.service("MenusResource",($resource,$location)->
			protocol = $location.protocol()
			host = $location.host()
			port = $location.port()
			domain = protocol+'://'+host+':'+port
			return $resource(domain+"/api/v1/menus/:id",{id:"@id"})
		)