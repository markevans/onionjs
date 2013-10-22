if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'jquery',
  'onion/errors',
  'onion/type'
], function(
  $,
  Errors,
  Type
){
  return Type.sub('Validator')

    .proto({
      __errorsOn__: function(attributes) {
        var errors = new Errors()
        this.__runValidations__(attributes, errors)
        return errors
      },

      validate: function(attributes) {
        var deferred = $.Deferred()

        var errors = this.__errorsOn__(attributes)
        if (errors.isEmpty()) {
          deferred.resolve()
        } else {
          deferred.reject(errors)
        }

        return deferred.promise()
      },

      __runValidations__: function(attributes, errors) {}
    })
})
