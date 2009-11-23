require 'treasury/monkey_patches'
require 'treasury/criterion'
require 'treasury/repository'
require 'treasury/stash'
require 'treasury/identifier'

module Treasury
  def self.[](klass)
    ((Thread.current[:repositories] ||= {})[klass] ||= Repository.new(klass))
  end

  def self.clear_all
    (Thread.current[:repositories] ||= {}).values.each do |r|
      r.clear
    end
  end
end
