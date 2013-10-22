if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/type',
  'onion/event_emitter',
  'onion/has_uuid'
], function (Type, eventEmitter, hasUUID) {

  return Type.sub('Model')

    .use(hasUUID)

    .proto(eventEmitter)

})

