function Queue() {
  if (!(this instanceof Queue)) {
    return new Queue;
  }

  this.tasks = [];
}

Queue.prototype.size = function() {
  return this.tasks.length;
};

Queue.prototype.addTask = function(task, context) {
  this.tasks.push({ task: task, context: context });
};

if (typeof exports !== 'undefined' && exports !== null) {
  exports.Queue = Queue;
} else if (typeof window !== 'undefined' && window !== null) {
  window.Queue = Queue;
}
