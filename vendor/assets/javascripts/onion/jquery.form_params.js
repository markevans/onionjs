if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['jquery'], function($) {

  function attrFromInputName(inputName, namespace){
    var matcher = new RegExp(namespace+'\\[(.+)\\]')
    return inputName.replace(matcher, '$1')
  }

  $.fn.formParams = function(namespace){
    // Normal params
    var params = this.serializeArray().
      reduce(function(params, input){
        if(namespace){
          if(input.name.match(namespace+'\\['))
            params[attrFromInputName(input.name, namespace)] = input.value
        } else {
          params[input.name] = input.value
        }
        return params;
      }, {});

    // Attached files
    this.find('input[type=file]').each(function(){
      if(this.files.length){
        params[this.name] = this.files[0]
      }
    })

    return params
  }

})
