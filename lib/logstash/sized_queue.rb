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
        @event_type_rates = {}
    end

    def <<(event)
        push(event)
    end

    def enq(event)
        push(event)
    end

    def push(event)
        if event['tracer'] 
            metric_name = "#{@name}.queue.in.#{event['tracer']['name']}"
            c_metric = @event_type_rates[metric_name] || LogStash.metrics_registry.meter("#{metric_name}.rate")
            c_metric.mark
        end
        @push_rate.mark
        super(event)
    end

    def pop
        event = super
        @pop_rate.mark
        if event['tracer'] 
            metric_name = "#{@name}.queue.out.#{event['tracer']['name']}"
            c_metric = @event_type_rates[metric_name] || LogStash.metrics_registry.meter("#{metric_name}.rate")
            c_metric.mark
        end
        event
    end

end

class QueueMetric
    include com.codahale.metrics.Gauge
    
    def initialize(q)
        @q = q
    end

    def getValue
        @q.length
    end
end

