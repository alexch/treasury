module Treasury

  # Storage is an abstract base class for the backing storage area of
  # a Repository. Concrete implementations include Stash (for in-memory
  # storage) and ActiveRecord (and in future, DataMapper, Sequel, Aqua, 
  # etc.) The base class will raise Unimplemented if a subclass 
  # neglects to implement a required method, viz. #size, #clear, #store_new,
  # #store_old, #find_by_keys, and #find_by_criterion

  class Storage

    class Unidentified < RuntimeError
    end

    class Unimplemented < RuntimeError
    end
    
    def self.for_class(klass)
      Keymaster.storage_for(klass).new(klass)
    end
    
    def self.key_for(object)
      object.treasury_key
    end

    def self.new?(object)
      object.treasury_key.nil?
    end

    def initialize(klass = nil)
      @klass = klass
    end

    def size
      raise Unimplemented
    end

    def clear
      raise Unimplemented
    end
    
    # Put an object, or an array of objects, into the storage.
    def store(objects)
      unless objects.is_a? Array
        objects = [objects]
      end
      new_objects = []
      old_objects = []
      objects.each do |object|
        if Keymaster.new?(object)
          new_objects << object
        else
          old_objects << object
        end
      end
      store_new(new_objects) unless new_objects.empty?
      store_old(old_objects) unless old_objects.empty?
    end

    # get an object by key
    def get(key)
      find_by_keys([key]).first
    end

    # alias for get
    def [](key)
      get(key)
    end

    # Finds all stashed objects that match the argument. Argument is either
    # a criterion, an key, or an array of either keys or criteria.
    # Returns an array of objects.
    def find(arg)
      if arg.is_a? Criterion
        find_by_criterion(arg)
      elsif arg.is_a? Array
        find_by_keys(arg)
      else
        find_by_keys([arg])
      end
    end
    
    protected
    
    def store_old(objects)
      raise Unimplemented
    end
      
    def store_new(objects)
      raise Unimplemented
    end
    
    def find_by_criterion(criterion)
      raise Unimplemented
    end
    
    def find_by_keys(keys)
      raise Unimplemented
    end
    
  end
end
