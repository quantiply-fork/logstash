# encoding: utf-8
#$: << File.join(File.dirname(__FILE__), "..", "..", "vendor", "bundle")

java_import 'com.codahale.metrics.MetricsRegistry'
java_import 'com.codahale.metrics.JmxReporter'
java_import 'com.codahale.metrics.Gauge'
java_import 'com.codahale.metrics.Meter'

module LogStash
  module Inputs; end
  module Outputs; end
  module Filters; end
  module Search; end
  module Config; end
  module File; end
  module Web; end
  module Util; end
  module PluginMixins; end

  SHUTDOWN = :shutdown

  @metrics_registry = MetricRegistry.new
  @jmx = JmxReporter.forRegistry(@metrics_registry).build()
  
  class << self
    attr_accessor :metrics_registry, :jmx
  end
end # module LogStash
