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
        @tracer_metrics = {}
        @count_metrics = {}
    end

    def push(event)
        if event[:tracer] 
            metric_name = "#{name}.queue.in.#{event[:tracer][:name]}"
            c_metric = @tracer_metrics[metric_name] || LogStash.metrics_registry.meter("#{metric_name}.rate")
            # t_metric = @tracer_metrics[metric_name] || LogStash.metrics_registry.register("#{metric_name}.trace", TracerMetric.new(0))
            # t_metric.update(event[:tracer][:count])
            c_metric.mark
        end
        @push_rate.mark
        super(event)
    end

    def pop
        @pop_rate.mark
        if event[:tracer] 
            metric_name = "#{name}.queue.out.#{event[:tracer][:name]}"
            c_metric = @tracer_metrics[metric_name] || LogStash.metrics_registry.meter("#{metric_name}.rate")
            # metric = @tracer_metrics[metric_name] || LogStash.metrics_registry.register(metric_name, TracerMetric.new(0))
            # metric.update(event[:tracer][:count])
            c_metric.mark
        end
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

class TracerMetric
    # java_implements 'com.codahale.metrics.Gauge'
    include com.codahale.metrics.Gauge
    
    def initialize(q)
        @q = q
    end

    def update(u)
        @q = u
    end

    # java_signature 'int getValue()'
    def getValue
        @q
    end
end

