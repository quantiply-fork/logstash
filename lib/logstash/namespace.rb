# encoding: utf-8
#$: << File.join(File.dirname(__FILE__), "..", "..", "vendor", "bundle")
jarpath = File.join(File.dirname(__FILE__), '../../vendor/jar/kafka*/libs/*.jar')
Dir[jarpath].each do |jar|
  require jar
end
require File.join(File.dirname(__FILE__), "../../vendor/jar/metrics-core-3.0.2.jar");

java_import 'com.codahale.metrics.MetricRegistry'
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
  @jmx = JmxReporter.forRegistry(@metrics_registry).inDomain('logstash').build
  
  class << self
    attr_accessor :metrics_registry, :jmx
  end
end # module LogStash
