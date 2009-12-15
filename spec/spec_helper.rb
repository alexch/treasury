$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'treasury'
require 'spec'
require 'spec/autorun'
require 'spec/domain'
require 'spec/matchers'


def capturing_output
  output = StringIO.new
  $stdout = output
  yield
  output.string
ensure
  $stdout = STDOUT
end

module Matchers
  # borrowed from http://github.com/aiwilliams/spec_goodies

  class IncludeOnly # :nodoc:all
    def initialize(*expected)
      @expected = expected.flatten
    end

    def matches?(actual)
      @missing = @expected.reject {|e| actual.include?(e)}
      @extra = actual.reject {|e| @expected.include?(e)}
      @extra.empty? && @missing.empty?
    end

    def failure_message
      message = "expected to include only #{@expected.inspect}"
      message << "\nextra: #{@extra.inspect}" unless @extra.empty?
      message << "\nmissing: #{@missing.inspect}" unless @missing.empty?
      message
    end

    def negative_failure_message
      "expected to include more than #{@expected.inspect}"
    end

    def to_s
      "include only #{@expected.inspect}"
    end
  end

  # Unlike checking that two Enumerables are equal, where the
  # objects in corresponding positions must be equal, this will
  # allow you to ensure that an Enumerable has all the objects
  # you expect, in any order; no more, no less.
  def include_only(*expected)
    IncludeOnly.new(*expected)
  end
end

Spec::Runner.configure do |config|
  include Matchers
end
