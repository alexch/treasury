require 'treasury/monkey_patches'
require 'treasury/criterion'
require 'treasury/repository'
require 'treasury/keymaster'
require 'treasury/storage'
require 'treasury/stash'
require 'treasury/stash_storage'
require 'treasury/active_record_storage'

module Treasury
  
  # methods on Treasury itself
  
  def self.repositories
    (@@repositories ||= {})
  end
  
  def self.repository(klass)
    self.repositories[klass] ||= Repository.new(klass)
  end
  
  def self.[](klass)
    self.repository(klass)
  end

  def self.clear_all
    self.repositories.values.each do |r|
      r.clear
    end
  end

  def self.[]=(klass, repository)
    self.repositories[klass] = repository
  end
  
  # methods on Treasury-enabled model classes that extend Treasury

  def repository
    Treasury[self]
  end
  
  def treasury_size
    repository.size
  end
  
  def store(*args)
    repository.store(*args)
  end

  def search(*args, &block)
    repository.search(*args, &block)
  end
  
  def clear_treasury
    repository.clear
  end
  
  def <<( *treasure )
    store( *treasure )
  end
  
  def [](arg)
    repository[arg]
  end

  def self.extended( klass )
    klass.class_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    def store
      self.class.store(self)
    end
  end
  
end
