define([
  'onion/type',
  'onion/class_declarations'
], function (Type, classDeclarations) {

  return Type.sub('Serializer')

    .use(classDeclarations, 'serializeRule')
    .use(classDeclarations, 'deserializeRule')

    .after('init', function () {
      this.__serializeRules__ = {}
      this.__deserializeRules__ = []
      this.__applyClassDeclarations__('serializeRule')
      this.__applyClassDeclarations__('deserializeRule')
    })

    .proto({

      serializeRule: function (name, paramsToString) {
        this.__serializeRules__[name] = paramsToString
      },

      deserializeRule: function (pattern, name, stringToParams) {
        this.__deserializeRules__.push({
          pattern: pattern,
          name: name,
          callback: stringToParams
        })
      },

      deserialize: function (string) {
        var rule, matches
        for(var i=0; i < this.__deserializeRules__.length; i++) {
          matches = this.__deserializeRules__[i].pattern.exec(string)
          if (matches) {
            rule = this.__deserializeRules__[i]
            break
          }
        }
        if (rule) {
          return {name: rule.name, params: rule.callback(string, matches)}
        } else {
          throw new Error('cannot deserialize "' + string + '"')
        }
      },

      serialize: function (name, params) {
        var rule = this.__serializeRules__[name]
        if (rule) {
          return rule(params)
        } else {
          throw new Error('cannot serialize with name "' + name + '"')
        }
      }

    })

})
