http = require 'http'
CheckAsWhitelist = require '../src/check-as-whitelist'

describe 'CheckAsWhitelist', ->
  beforeEach ->
    @whitelistManager =
      canDiscoverAs: sinon.stub()

    @sut = new CheckAsWhitelist
      whitelistManager: @whitelistManager

  describe '->do', ->
    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @whitelistManager.canDiscoverAs.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'bright-green'
            fromUuid: 'dim-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 204', ->
        expect(@newJob.metadata.code).to.equal 204

      it 'should get have the status of ', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a valid job without a fromUuid', ->
      beforeEach (done) ->
        @whitelistManager.canDiscoverAs.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'bright-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@whitelistManager.canDiscoverAs).to.have.been.calledWith toUuid: 'green-blue', fromUuid: 'green-blue'

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @whitelistManager.canDiscoverAs.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-lime-green'
            toUuid: 'hot-yellow'
            fromUuid: 'ugly-yellow'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 204', ->
        expect(@newJob.metadata.code).to.equal 204

      it 'should get have the status of OK', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a job that with a device that cannot be discovered', ->
      beforeEach (done) ->
        @whitelistManager.canDiscoverAs.yields null, false
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'super-purple'
            fromUuid: 'not-so-super-purple'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@newJob.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called and the canDiscoverAs yields an error', ->
      beforeEach (done) ->
        @whitelistManager.canDiscoverAs.yields new Error "black-n-black"
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'green-bomb'
            fromUuid: 'green-safe'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 500', ->
        expect(@newJob.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[500]
