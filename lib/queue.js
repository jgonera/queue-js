function Queue(parallelism) {
  if (!(this instanceof Queue)) {
    return new Queue(parallelism);
  }

  this.tasks = [];
  this.callbacks = [];
  this.running = 0;
  this.parallelism = typeof parallelism === 'undefined' ? 1 : parallelism;
  if (this.parallelism < 1) {
    throw new Error("parallelism argument can't be less than 1");
  }
}

Queue.prototype.size = function() {
  return this.tasks.length;
};

Queue.prototype.isRunning = function() {
  return this.running !== 0;
};

Queue.prototype.inFlight = function() {
  return this.running;
};

Queue.prototype.addTask = function(task, context) {
  this.tasks.push({ fn: task, context: context });
  return this;
};

Queue.prototype.addCallback = function(callback, context) {
  this.callbacks.push({ fn: callback, context: context });
  return this;
};

Queue.prototype.start = function() {
  var self = this;

  function runCallbacks() {
    var callback;
    while (callback = self.callbacks.shift()) {
      try {
        callback.fn.call(callback.context || self, self);
      } catch (e) {
        // TODO: log this
      }
    }
  }

  function startTask() {
    var task = self.tasks.shift();
    if (task) {
      try {
        task.fn.call(task.context || self, startTask);
      } catch (e) {
        startTask();
        // TODO: log this
      }
    } else {
      self.running -= 1;
      if (self.running === 0) runCallbacks();
    }
  }

  if (!this.isRunning()) {
    for (var i=0; i<this.parallelism; ++i) {
      startTask();
      this.running += 1;
    }
  }

  return this;
};

if (typeof exports !== 'undefined' && exports !== null) {
  exports.Queue = Queue;
} else if (typeof window !== 'undefined' && window !== null) {
  window.Queue = Queue;
}
