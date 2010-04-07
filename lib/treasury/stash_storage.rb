module Treasury 
  class StashStorage < Storage

    attr_reader :stash
    
    def initialize(klass, stash = Stash.new)
      raise "nope" if klass.is_a? Stash
      raise "nuh-uh" unless stash.is_a? Stash
      super(klass)
      @stash = stash
    end
    
    def size
      @stash.size
    end

    def clear
      @stash.clear
    end

    def store_old(objects)
      @stash.put(objects)
    end

    def store_new(objects)
      raise Unimplemented
    end

    def find_by_criterion(criterion)
      @stash.find(criterion)
    end

    def find_by_keys(keys)
      @stash.find(keys)
    end

  end
end
