Validator = requirejs('onion/validator')

describe "Validator", ->

  describe "validate", ->
    attributes = null
    validator = null

    beforeEach ->
      attributes = {}
      validator = new Validator()

    describe "when valid", ->
      beforeEach ->
        validator.__runValidations__ = ->

      it "calls the done callback", ->
        callback = sinon.spy()
        validator.validate(attributes).done(callback)
        assert.isTrue( callback.called )

      it "doesn't call the fail callback", ->
        callback = sinon.spy()
        validator.validate(attributes).fail(callback)
        assert.isFalse( callback.called )

    describe "when invalid", ->
      ourErrors = null

      beforeEach ->
        validator.__runValidations__ = (attributes, errors) ->
          ourErrors = errors
          errors.add('type', 'bad')

      it "doesn't call the done callback when invalid", ->
        callback = sinon.spy()
        validator.validate(attributes).done(callback)
        assert.isFalse( callback.called )

      it "calls the fail callback when invalid", ->
        callback = sinon.spy()
        validator.validate(attributes).fail(callback)
        assert.isTrue( callback.calledWith(ourErrors) )
