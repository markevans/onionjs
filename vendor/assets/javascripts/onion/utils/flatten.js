if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function () {
  return function (object) {
    var key, innerKey, flat = {}
    for(key in object) {
      if(typeof object[key] == 'object') {
        for(innerKey in object[key]) {
          flat[innerKey] = object[key][innerKey]
        }
      } else {
        flat[key] = object[key]
      }
    }
    return flat
  }
})
