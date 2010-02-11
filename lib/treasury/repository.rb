# http://martinfowler.com/eaaCatalog/repository.html
# http://www.infoq.com/resource/minibooks/domain-driven-design-quickly/en/pdf/DomainDrivenDesignQuicklyOnline.pdf p.51
module Treasury
  class Repository

    attr_reader :klass
    attr_accessor :store

    def initialize(klass)
      @klass = klass
      @stash = Stash.new
      @store = Keymaster.store_for(klass).new
    end

    def size
      @stash.size
    end

    def clear
      @stash.clear
    end

    def <<(args)
      put(args)
    end

    def put(*arg)
      arg.flatten!
      arg.each do |object|
        raise ArgumentError, "expected #{@klass} but got #{object.class}" unless object.is_a?(klass)
      end
      store.put(arg)
      @stash.put(arg)
      arg.each do |object|
        object.entered_repository if object.respond_to?(:entered_repository)
      end
    end

    def [](id)
      objects = search(id)
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
        find_ids(arg)
      when Fixnum
        find_ids([arg])
      when Criterion::Id
        find_ids_in_criterion(arg)
      when String
        find_ids([arg.to_i])
      when Criterion
        find_by_criterion(arg)
      else
        raise "???"
      end
    end
    
    def extract(arg = nil, &block)
      search(arg, &block).map{|o| @store.class.key_for(o)}
    end

    def criterion_from
      yield Criterion::Factory
    end
    
    protected

    def find_ids_in_criterion(criterion)
      find_ids(criterion.value)
    end
    
    def find_ids(ids)
      raise "Nil argument" if ids.nil?
      
      found = []
      needed = []
      ids.each do |id|
        raise ArgumentError, "illegal argument #{id.inspect}" if id.to_i == 0
        id = id.to_i
        unless (object = @stash[id])
          needed << id
        end
      end

      unless needed.empty?
        needed.sort!.uniq! # the sort is just to make debugging easier
        ActiveRecord::Base.logger.info("#{klass.name} Repository hitting DB from #{calling_function}")

        found_in_store = store.find(needed).compact

        if found_in_store.size != needed.size
          missing = (needed - found_in_store.map(&:id))
          ActiveRecord::Base.logger.warn "Warning: couldn't find #{missing.size} out of #{needed.size} #{klass.name.pluralize}: missing ids #{missing.join(',')}"
        end

        put(found_in_store)
      end
      ids.map{|id| @stash[id]} # find again so they come back in order
    end
    
    def find_by_criterion(criterion)
      results = store.find(criterion)
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
