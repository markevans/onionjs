if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['onion/uuid'], function (uuid) {
  return function (Constructor) {
    Constructor

      .proto({
        uuid: function () {
          if (!this.__uuid__) this.__uuid__ = uuid()
          return this.__uuid__
        }
      })
  }
})

