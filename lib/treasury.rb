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

  def repository
    Treasury[self]
  end
  
  def treasury_size
    repository.size
  end
  
  def put(*args)
    repository.put(*args)
  end
  
  def search(*args)
    repository.find(*args)
  end
  
  def self.extended( klass )
    klass.class_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    def put
      self.class.put(self)
    end
  end
  
end
