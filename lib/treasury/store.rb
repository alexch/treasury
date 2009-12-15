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
    def put(object)
      unless object.is_a? Array
        object = [object]
      end
      new_objects = []
      old_objects = []
      object.each do |o|
        if Identifier.new?(object)
          new_objects << o
        else
          old_objects << o
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
    
    class ActiveRecord < Store
      def find_by_ids(ids)
        @klass.find(:all, :conditions => ["id IN (?)", ids])
      end
    end
  end
end
