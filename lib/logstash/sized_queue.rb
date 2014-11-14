# encoding: utf-8
require "logstash/namespace"
require "logstash/logging"
require "java"

require "thread" # for SizedQueue
class LogStash::SizedQueue < SizedQueue

  # TODO(sissel): Soon will implement push/pop stats, etc

    def initialize(size, name="")
        super(size)
        @name = name
        LogStash.metrics_registry.register("#{name}.queue.size", QueueMetric.new(self))
        @push_rate = LogStash.metrics_registry.meter("#{name}.push.rate")
        @pop_rate = LogStash.metrics_registry.meter("#{name}.pop.rate")
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

class QueueMetric
    # java_implements 'com.codahale.metrics.Gauge'
    include com.codahale.metrics.Gauge
    
    def initialize(q)
        @q = q
    end

    # java_signature 'int getValue()'
    def getValue
        @q.length
    end
end

