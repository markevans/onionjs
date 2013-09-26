if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function () {
  return function (object, spec) {
    var namespace

    /* First create a lookup for each found key */
    var lookup = {}
    for(namespace in spec) {
      spec[namespace].forEach(function (key) {
        lookup[key] = namespace
      })
    }

    /* Populate unflattened object */
    var unflat = {}, key
    for(key in object) {
      if( namespace = lookup[key] ) {
        if( !unflat[namespace] ) unflat[namespace] = {}
        unflat[namespace][key] = object[key]
      } else {
        unflat[key] = object[key]
      }
    }
    return unflat
  }
})
