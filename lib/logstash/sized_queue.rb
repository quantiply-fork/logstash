# encoding: utf-8
require "logstash/namespace"
require "logstash/logging"

require "thread" # for SizedQueue
class LogStash::SizedQueue < SizedQueue

  # TODO(sissel): Soon will implement push/pop stats, etc

    def initialize(size, name="")
        super(size)
        @name = name
        LogStash.metrics_registry.register("queue.size", QueueMetric.new(self))
        @push_rate = LogStash.metrics_registry.meter("push.rate")
        @pop_rate = LogStash.metrics_registry.meter("pop.rate")
    end

    def push(event)
        @push_rate.mark
        super(event)
    end

    def pop
        @pop_rate.mark
        super
    end

end

class QueueMetric < Gauge
    def initialize(q)
        @q = q
    end

    def getValue
        q.size
    end
end

