if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['onion/uuid'], function (uuid) {
  return function (Constructor) {
    Constructor

      .before('init', function () {
        this.__uuid__ = uuid()
      })

      .proto({
        uuid: function () {
          return this.__uuid__
        }
      })
  }
})

