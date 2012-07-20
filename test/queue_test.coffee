{Queue} = require '..'

describe "Queue", ->
  q = null
  beforeEach ->
    q = Queue()

  it "works when constructed with 'new' keyword"

  describe "#size", ->
    it "returns 0 for empty queue", ->
      q.size().should.equal 0

  describe "#addTask", ->
    it "increases the size by one", ->
      q.addTask -> console.log "doing nothing"
      q.size().should.equal 1

