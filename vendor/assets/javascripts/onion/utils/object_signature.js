if(typeof define!=='function'){var define=require('amdefine')(module)}

define(function(){

  var f = function (object) {
    var sig = ""
    Object.keys(object).sort().forEach(function (key) {
      var value = (typeof object[key] == 'object') ? f(object[key]): object[key]
      sig += [key, value].join('')
    })
    return sig
  }

  return f

})
