# a Stash is a glorified hashtable, used for keeping objects in memory
# and indexing them by id. Any objects put into the stash must have an
# id, as identified by the Keymaster class. A stash is used by Repository
# to keep the objects it recieves from its Store.
module Treasury
  class Stash

    attr_reader :data # for debugging only

    def initialize
      @data = {}
    end

    def size
      @data.size
    end

    def clear
      @data = {}
    end

    # Put an object, or an array of objects, into the stash.
    # All such objects must be identifiable by the Keymaster class;
    # if not, this will raise a Treasury::Store::Unidentified exception
    # (possibly leaving some remaining items unstashed).
    def put(object)
      if object.is_a? Array
        object.each do |o|
          put(o)
        end
      else
        key = Keymaster.key_for(object)
        raise Treasury::Store::Unidentified, "you can't stash an object without a key" unless key
        @data[key] = object
      end
    end

    # get an object by id
    def get(key)
      @data[key]
    end
    
    alias_method :[], :get

    # Finds all stashed objects that match the argument. Argument is either
    # a criterion, an id, or an array of either ids or criteria.
    # Returns an array of objects.
    def find(arg)
      if arg.is_a? Criterion
        @data.values.select{|object| arg.match? object}
      elsif arg.is_a? Array
        arg.map{|key| get(key)}
      else
        [get(arg)]
      end
    end

  end
end
