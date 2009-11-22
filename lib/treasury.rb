require 'monkey_patches'

require 'criterion'
require 'repository'
require 'stash'
require 'identifier'

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
