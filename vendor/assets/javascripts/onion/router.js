define([
  'onion/type',
  'onion/event_emitter',
  'onion/class_declarations',
  'onion/regexp_escape'
], function (Type, eventEmitter, classDeclarations, regexpEscape) {

  function Route(name, pattern){
    this.name = name
    this.pattern = pattern
    this.__parsePattern__()
  }
  Route.prototype = {
    matches: function (path) {
      return this.regexp.test(path.split('?')[0])
    },

    pathToParams: function (path) {
      var params = {},
          parts = path.split('?'),
          pathSegment = parts[0],
          query = parts[1],
          matches = this.regexp.exec(pathSegment)

      // Add params from path segment
      for (var i=1; i < matches.length; i++) {
        params[this.keyNames[i-1]] = matches[i]
      }

      // Add params from part after the question mark
      if (query) {
        query.split('&').forEach(function (p) {
          var parts = p.split('=')
          params[parts[0]] = parts[1]
        })
      }

      return params
    },

    paramsToPath: function (params) {
      var path = this.pattern,
          query = ""
      for(var key in params) {
        var segment = ":"+key
        if (path.match(segment)) {
          path = path.replace(segment, params[key])
        } else {
          if (params[key]) {
            if (query) { query += '&' }
            query += [key, params[key]].join('=')
          }
        }
      }
      return query ? [path,query].join('?') : path
    },

    __parsePattern__: function () {
      this.keyNames = []
      // e.g. for pattern '/:hello/:there'
      var rx = regexpEscape(this.pattern).replace(/:\w+/g, function (key) {
        this.keyNames.push(key.slice(1)) // Take the ':' off the ':hello'
        return '(\\w+)'
      }.bind(this))
      this.regexp = new RegExp('^'+rx+'$')
    }
  }

  return Type.sub('Router')

    .use(classDeclarations, 'route')

    .after('init', function () {
      this.__routes__ = []
      this.__routesLookup__ = {}
      this.__applyClassDeclarations__('route')
    })

    .proto(eventEmitter)

    .proto({

      route: function (name, pattern) {
        var route = new Route(name, pattern)
        this.__routes__.push(route)
        this.__routesLookup__[name] = route
        return route
      },

      process: function (path) {
        var result = this.match(path)
        if (result) this.emit('route', result.name, result.params)
      },

      match: function (path) {
        var route
        for(var i=0; i < this.__routes__.length; i++) {
          if (this.__routes__[i].matches(path)) {
            route = this.__routes__[i]
            break
          }
        }
        if (route) {
          return {name: route.name, params: route.pathToParams(path)}
        } else {
          console.log("Router didn't match path " + path)
          return null
        }
      },

      path: function (name, params) {
        var route = this.__routesLookup__[name]
        if (route) {
          return route.paramsToPath(params)
        } else {
          throw new Error("route " + name + " does not exist")
        }
      }

    })

})

