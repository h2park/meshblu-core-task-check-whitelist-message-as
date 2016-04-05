http = require 'http'
CheckWhitelistMessageAs = require '../'

describe 'CheckWhitelistMessageAs', ->
  beforeEach ->
    @whitelistManager =
      checkMessageAs: sinon.stub()

    @sut = new CheckWhitelistMessageAs
      whitelistManager: @whitelistManager

  describe '->do', ->
    describe 'when called with no as', ->
      beforeEach (done) ->
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of ', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageAs.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
              as: 'dim-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of ', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

      it 'should call the whitelistManager checkMessageAs with the auth.uuid and the auth.as', ->
        expect(@whitelistManager.checkMessageAs).to.have.been.calledWith
          emitter: 'dim-green'
          subscriber: 'green-blue'

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageAs.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-lime-green'
              as: 'ugly-yellow'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of OK', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a job that with a device that has an invalid whitelist', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageAs.yields null, false
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
              as: 'not-so-super-purple'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@response.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called and the checkMessageAs yields an error', ->
      beforeEach (done) ->
        @whitelistManager.checkMessageAs.yields new Error "black-n-black"
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
              as: 'green-safe'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 500', ->
        expect(@response.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[500]
