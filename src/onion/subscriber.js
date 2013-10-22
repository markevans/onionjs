if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function(){

  return {
    subscriptions: function(){
      if(!this.__subscriptions__) this.__subscriptions__ = []
      return this.__subscriptions__
    },
    
    subscribe: function(publisher, event, callback){
      var subscriptions = this.subscriptions()
      var subscriptionID = Object.keys(subscriptions).length,
          args = [event, callback.bind(this)]

      subscriptions[subscriptionID] = {publisher: publisher, args: args}

      publisher.on.apply(publisher, args)
      return subscriptionID
    },

    unsubscribe: function(id){
      var subscriptions = this.subscriptions()
      var sub = subscriptions[id]
      if(sub){
        sub.publisher.off.apply(sub.publisher, sub.args);
        delete subscriptions[id]
      }
    },
     
    unsubscribeAll: function(){
      for(var id in this.subscriptions()){
        this.unsubscribe(id)
      }
    }
  }

})
