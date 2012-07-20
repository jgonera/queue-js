if typeof exports != 'undefined' and exports != null
  {Queue} = require '..' if typeof exports != 'undefined' and exports != null
else if typeof window != 'undefined' and window != null
  Queue = window.Queue

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
      q.addTask(createTask())
      q.size().should.equal 1

    it "returns Queue", ->
      obj = q.addTask(createTask())
      obj.should.equal q

  describe "#addCallback", ->
    it "returns Queue", ->
      obj = q.addCallback -> null
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

    it "reduces the size after running tasks", ->
      task1 = createTask(100)
      task2 = createTask()
      q.addTask(task1).addTask(task2)
      q.start()
      q.size().should.equal 1

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

    it "runs tasks after errors in previous tasks", ->
      task1 = sinon.stub().throws()
      task2 = createTask()
      q.addTask(task1).addTask(task2)
      q.start()
      task2.should.have.been.calledOnce

    it "runs callbacks after tasks", ->
      callback1 = sinon.spy()
      callback2 = sinon.spy()
      q.addTask(createTask()).addCallback(callback1).addCallback(callback2)
      q.start()
      clock.tick()
      callback1.should.have.been.calledOnce
      callback2.should.have.been.calledOnce

    it "runs callbacks with the default context of queue", ->
      callback = sinon.spy()
      q.addTask(createTask()).addCallback(callback)
      q.start()
      clock.tick()
      callback.should.have.been.calledOn q

    it "runs callbacks in specific context", ->
      callback = sinon.spy()
      context = {}
      q.addTask(createTask()).addCallback(callback, context)
      q.start()
      clock.tick()
      callback.should.have.been.calledOn context

    it "runs callbacks after errors in previous callbacks", ->
      callback1 = sinon.stub().throws()
      callback2 = sinon.spy()
      q.addTask(createTask()).addCallback(callback1).addCallback(callback2)
      q.start()
      clock.tick()
      callback2.should.have.been.calledOnce

    it "has no effect when invoked more than once", ->
      task1 = createTask(100)
      task2 = createTask()
      q.addTask(task1).addTask(task2)
      q.start()
      q.start()
      task2.should.not.have.been.called

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
      
