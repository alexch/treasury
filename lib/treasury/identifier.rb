begin
  require 'active_record' # todo: make optional
rescue LoadError
  require 'rubygems'
  require 'active_record'
end

module Treasury
  class Identifier

    def self.register(object_class, store_class)
      (@stores ||= {})[object_class] = store_class
    end
    
    def self.store_for(object)
      (@stores ||= {}).each_pair do |object_class, store_class|
        if (object.is_a?(Class) && object.ancestors.include?(object_class)) ||
           (object.is_a?(object_class))
          return store_class
        end
      end
      
      if (object.is_a?(Class) && object.is_a?(Treasury)) ||
         (object.class.is_a?(Treasury))
        return StashStore
      end
      raise "Couldn't find store class for #{object.inspect}"
    end
    
    def self.new?(object)
      store_for(object).new?(object)
    end
    
    def self.key_for(object)
      if new?(object)
        nil
      else
        store_for(object).key_for(object)
      end
    end
  end
end
