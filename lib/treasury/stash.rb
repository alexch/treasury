module Treasury
  class Stash

    class Unidentified < RuntimeError
    end
    
    attr_reader :data # for debugging only
    def inspect
      "hi"
    end
    
    def initialize
      @data = {}
    end

    def size
      @data.size
    end

    def clear
      @data = {}
    end

    def put(object)
      if object.is_a? Array
        object.each do |o|
          put(o)
        end
      else
        key = Identifier.id(object)
        raise Unidentified, "you can't stash an object without an id" unless key
        @data[key] = object
      end
    end

    def get(key)
      @data[key]
    end

    def [](key)
      get(key)
    end

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
