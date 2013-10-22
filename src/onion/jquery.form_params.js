if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['jquery'], function($) {

  function attrFromInputName(inputName, namespace){
    var matcher = new RegExp(namespace+'\\[(.+)\\]')
    return inputName.replace(matcher, '$1')
  }

  function doWithKey(namespace, inputName, callback) {
    if (namespace) {
      if (inputName.match(namespace+'\\[')) {
        callback(attrFromInputName(inputName, namespace))
      }
    } else {
      callback(inputName)
    }
  }

  $.fn.formParams = function(namespace){

    // Normal params
    var params = this.serializeArray().
      reduce(function(params, input){
        doWithKey(namespace, input.name, function (key) {
          params[key] = input.value
        })
        return params;
      }, {});

    // Unchecked checkboxes
    this.find('input[type=checkbox]:not(:checked)').each(function () {
      doWithKey(namespace, this.name, function (key) {
        params[key] = null
      })
    })

    // Attached files
    this.find('input[type=file]').each(function(){
      if(this.files.length){
        params[this.name] = this.files[0]
      }
    })

    return params
  }

})
