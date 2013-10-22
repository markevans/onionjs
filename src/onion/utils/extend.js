if(typeof define!=='function'){var define=require('amdefine')(module)}

define(function(){
  
  return function (destination) {
    if (destination !== Object(destination)) throw new TypeError('Object.extend was passed a non-object')
    var sources = Array.prototype.slice.call(arguments, 1)
    sources.forEach(function (source) {
      for (var property in source) {
        if (source.hasOwnProperty(property)) {
          destination[property] = source[property]
        }
      }
    })
    return destination
  }

})
