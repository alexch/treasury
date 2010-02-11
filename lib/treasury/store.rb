module Treasury

  # Store is an abstract base class for the backing storage area of 
  # a Repository. Concrete implementations include Stash (for in-memory
  # storage) and ActiveRecord (and in future, DataMapper, Sequel, Aqua, 
  # etc.) The base class will raise Unimplemented if a subclass 
  # neglects to implement a required method, viz. #size, #clear, #put_new,
  # #put_old, #find_by_ids, and #find_by_criterion

  class Store

    class Unidentified < RuntimeError
    end

    class Unimplemented < RuntimeError
    end
    
    def self.for_class(klass)
      Keymaster.store_for(klass).new(klass)
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
    
    # Put an object, or an array of objects, into the store.
    def put(objects)
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
      put_new(new_objects) unless new_objects.empty?
      put_old(old_objects) unless old_objects.empty?
    end

    # get an object by id
    def get(key)
      find_by_ids([key]).first
    end

    # alias for get
    def [](key)
      get(key)
    end

    # Finds all stashed objects that match the argument. Argument is either
    # a criterion, an id, or an array of either ids or criteria.
    # Returns an array of objects.
    def find(arg)
      if arg.is_a? Criterion
        find_by_criterion(arg)
      elsif arg.is_a? Array
        find_by_ids(arg)
      else
        find_by_ids([arg])
      end
    end
    
    protected
    
    def put_old(objects)
      raise Unimplemented
    end
      
    def put_new(objects)
      raise Unimplemented
    end
    
    def find_by_criterion(criterion)
      raise Unimplemented
    end
    
    def find_by_ids(ids)
      raise Unimplemented
    end
    
  end
end
