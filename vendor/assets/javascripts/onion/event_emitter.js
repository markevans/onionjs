if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['vendor/supplement-0.1.1.min'], function(){

  return {
    channels: function(){
      if(!this.__channels__) this.__channels__ = {}
      return this.__channels__
    },

    emit: function(event){
      if(this.__silent__) return

      var subscriptions = this.channels()[event]
      var args = Array.prototype.slice.call(arguments, 1)
      if(subscriptions){
        subscriptions.forEach(function(sub){
          sub.callback.apply(this, args)
        })
      }
    },

    on: function(event, callback){
      var channels = this.channels()
      if(!channels[event]){ channels[event] = [] }
      channels[event].push({
        event: event,
        callback: callback
      })
      return this
    },

    one: function(event, callback) {
      var self = this
      var autodisablingCallback = function(){
        self.off(event, autodisablingCallback)
        callback.apply(this, Array.prototype.slice.call(arguments))
      }
      return this.on(event, autodisablingCallback)
    },

    off: function(event, callback){
      var channels = this.channels()
      if(channels[event]){
        channels[event] = channels[event].reject(function(sub){
          return sub.event == event && sub.callback == callback
        })
      }
      return this
    },

    silently: function(callback){
      this.__silent__ = true
      callback()
      this.__silent__ = false
    }
  }

})
