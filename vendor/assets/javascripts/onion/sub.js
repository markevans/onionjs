if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['onion/extend'], function(extend){

  var chainPrototype = function (child, parent) {
    function ctor() {
      this.constructor = child
    }
    ctor.prototype = parent.prototype
    child.prototype = new ctor()
  }

  return function (child, parent) {
    extend(child, parent)
    chainPrototype(child, parent)
  }
})
