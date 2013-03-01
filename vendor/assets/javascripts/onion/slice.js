if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function () {
  return function (attrs) {
    var obj = {}
    var keys = Array.prototype.slice.call(arguments, 1)
    keys.forEach(function (key) {
      if (Object.prototype.hasOwnProperty.call(attrs, key)) {
        obj[key] = attrs[key]
      }
    })
    return obj
  }
})
