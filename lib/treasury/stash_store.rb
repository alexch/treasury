module Treasury 
  class StashStore < Store

    attr_reader :stash
    
    def initialize(stash = Stash.new)
      @stash = stash
    end
    
    def size
      @stash.size
    end

    def clear
      @stash.clear
    end

    def put_old(objects)
      @stash.put(objects)
    end

    def put_new(objects)
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
