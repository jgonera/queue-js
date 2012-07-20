{Queue} = require '..'

createTask = (delay=0) ->
  sinon.spy (callback) -> setTimeout callback, delay

describe "Queue", ->
  q = clock = null
  beforeEach -> q = new Queue
  before -> clock = sinon.useFakeTimers()
  after -> clock.restore()

  it "works when created without `new` keyword", ->
    q = Queue()
    q.should.be.an.instanceof Queue

  it "throws an error when `parallelism` < 1", ->
    (-> new Queue(0)).should.throw(/parallelism/)

  describe "#size", ->
    it "returns 0 for empty queue", ->
      q.size().should.equal 0

  describe "#addTask", ->
    it "increases the size by one", ->
      q.addTask -> console.log "doing nothing"
      q.size().should.equal 1

    it "returns Queue", ->
      obj = q.addTask createTask()
      obj.should.equal q

  describe "#start", ->
    it "runs the tasks in order", ->
      task1 = createTask()
      task2 = createTask()
      q.addTask(task1).addTask(task2)
      q.start()
      clock.tick()
      task1.should.have.been.calledOnce
      task2.should.have.been.calledOnce
      task2.should.have.been.calledAfter task1

    it "runs at most `parallelism` tasks", ->
      task1 = createTask(100)
      task2 = createTask()
      q.addTask(task1).addTask(task2)
      q.start()
      task1.should.have.been.calledOnce
      task2.should.not.have.been.called
      clock.tick(150)
      task2.should.have.been.calledOnce

    it "runs tasks with the default context of queue", ->
      task = createTask()
      q.addTask(task)
      q.start()
      task.should.have.been.calledOn q

    it "runs tasks in specific context", ->
      task = createTask()
      context = {}
      q.addTask(task, context)
      q.start()
      task.should.have.been.calledOn context

    it

  describe "#isRunning", ->
    it "returns false before starting", ->
      q.isRunning().should.be.false

    it "returns true when running", ->
      q.addTask(createTask(100))
      q.start()
      q.isRunning().should.be.true

    it "returns false after finishing", ->
      q.addTask(createTask(100))
      q.start()
      clock.tick(150)
      q.isRunning().should.be.false

  describe "#inFlight", ->
    it "returns the number of tasks currently running", ->
      q = new Queue(2)
      task1 = createTask(100)
      task2 = createTask(200)
      q.addTask(task1).addTask(task2)
      q.start()
      q.inFlight().should.be.equal 2

    it "returns correct number after a task finishes", ->
      q = new Queue(2)
      task1 = createTask(100)
      task2 = createTask(200)
      q.addTask(task1).addTask(task2)
      q.start()
      clock.tick(150)
      q.inFlight().should.be.equal 1
      
