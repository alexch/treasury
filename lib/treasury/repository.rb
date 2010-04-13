# http://martinfowler.com/eaaCatalog/repository.html
# http://www.infoq.com/resource/minibooks/domain-driven-design-quickly/en/pdf/DomainDrivenDesignQuicklyOnline.pdf p.51
module Treasury
  class Repository

    attr_reader :klass
    attr_accessor :storage

    def initialize(klass)
      @klass = klass
      @stash = Stash.new
      @storage = Keymaster.storage_for(klass).new(klass)
    end

    def size
      @stash.size
    end

    # todo: clean up ambiguity between clearing the stash and clearing the storage
    def clear
      @stash.clear
    end

    def <<(args)
      store(args)
    end

    def store(*arg)
      arg.flatten!
      arg = arg.select do |object|
        if object.is_a?(Fixnum)
          false
        elsif !object.is_a?(klass)
          raise ArgumentError, "expected #{@klass} but got #{object.class}"
        else
          true
        end
      end
      storage.store(arg)
      @stash.put(arg)
      arg.each do |object|
        object.entered_repository if object.respond_to?(:entered_repository)
      end
    end

    def [](key)
      objects = search(key)
      if objects.empty?
        nil
      else
        objects.first
      end
    end

    def search(arg = nil, &block)
      if (arg.nil? && !block_given?) || (block_given? && !arg.nil?)
        raise "Must pass either an argument or a block to Repository#search"
      end
      
      arg = criterion_from &block if block_given?
      
      case arg
      when Array
        find_keys(arg)
      when Fixnum
        find_keys([arg])
      when Criterion::Key
        find_keys_in_criterion(arg)
      when String
        find_keys([arg.to_i])
      when Criterion
        find_by_criterion(arg)
      else
        raise "???"
      end
    end
    
    def extract(arg = nil, &block)
      search(arg, &block).map{|o| @storage.class.key_for(o)}
    end

    # This is the method that's called when you pass a block into search.
    # It passes the Criterion::Factory as a block parameter. 
    def criterion_from
      yield Criterion::Factory
    end
    
    protected

    def find_keys_in_criterion(criterion)
      find_keys(criterion.value)
    end
    
    def find_keys(keys)
      raise "Nil argument" if keys.nil?
      
      found = []
      needed = []
      keys.each do |key|
        raise ArgumentError, "illegal argument #{key.inspect}" if key.to_i == 0
        key = key.to_i
        unless (object = @stash[key])
          needed << key
        end
      end

      unless needed.empty?
        needed.sort!.uniq! # the sort is just to make debugging easier
        if ActiveRecord::Base.logger # todo: use a more general way to get a logger
          ActiveRecord::Base.logger.info("#{klass.name} Repository hitting storage from #{calling_function}")
        end

        found_in_storage = storage.find(needed).compact

        if found_in_storage.size != needed.size
          missing = (needed - found_in_storage.map(&:key))
          ActiveRecord::Base.logger.warn "Warning: couldn't find #{missing.size} out of #{needed.size} #{klass.name.pluralize}: missing keys #{missing.join(',')}"
        end

        store(found_in_storage)
      end
      keys.map{|key| @stash[key]} # find again so they come back in order
    end
    
    def find_by_criterion(criterion)
      results = criterion.find_in(storage)
      self << results
      results
    end

    def calling_function
      c = caller.detect{|line| line !~ /treasury/} || caller[2]
      c.gsub!("#{File.expand_path(File.dirname(RAILS_ROOT))}/", '') if defined?(RAILS_ROOT)
      c
    end

  end
end
