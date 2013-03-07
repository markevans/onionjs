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
        callback = jasmine.createSpy()
        validator.validate(attributes).done(callback)
        expect( callback ).toHaveBeenCalled()

      it "doesn't call the fail callback", ->
        callback = jasmine.createSpy()
        validator.validate(attributes).fail(callback)
        expect( callback ).not.toHaveBeenCalled()

    describe "when invalid", ->
      ourErrors = null

      beforeEach ->
        validator.__runValidations__ = (attributes, errors) ->
          ourErrors = errors
          errors.add('type', 'bad')

      it "doesn't call the done callback when invalid", ->
        callback = jasmine.createSpy()
        validator.validate(attributes).done(callback)
        expect( callback ).not.toHaveBeenCalled()

      it "calls the fail callback when invalid", ->
        callback = jasmine.createSpy()
        validator.validate(attributes).fail(callback)
        expect( callback ).toHaveBeenCalledWith(ourErrors)
