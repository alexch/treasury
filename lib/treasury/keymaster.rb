begin
  require 'active_record' # todo: make optional
rescue LoadError
  require 'rubygems'
  require 'active_record'
end

module Treasury
  class Keymaster

    def self.register(object_class, storage_class)
      (@storages ||= {})[object_class] = storage_class
    end
    
    def self.storage_for(object)
      (@storages ||= {}).each_pair do |object_class, storage_class|
        if (object.is_a?(Class) && object.ancestors.include?(object_class)) ||
           (object.is_a?(object_class))
          return storage_class
        end
      end
      
      if (object.is_a?(Class) && object.is_a?(Treasury)) ||
         (object.class.is_a?(Treasury))
        return StashStorage
      end
      raise "Couldn't find storage class for #{object.inspect}"
    end
    
    def self.new?(object)
      storage_for(object).new?(object)
    end
    
    def self.key_for(object)
      if new?(object)
        nil
      else
        storage_for(object).key_for(object)
      end
    end
  end
end
