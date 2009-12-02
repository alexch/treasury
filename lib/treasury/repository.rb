# http://martinfowler.com/eaaCatalog/repository.html
# http://www.infoq.com/resource/minibooks/domain-driven-design-quickly/en/pdf/DomainDrivenDesignQuicklyOnline.pdf p.51
module Treasury
  class Repository

    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @stash = Stash.new
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
      raise "can't put nil" if arg.nil?
      arg.flatten!
      arg.each do |object|
        raise ArgumentError, "expected #{@klass} but got #{object.class}" unless object.is_a?(klass)
        if Identifier.new?(object)
          object.save!  # todo: store.save(object)
        end
      end
      @stash.put(arg)
      arg.each do |object|
        object.entered_repository if object.respond_to?(:entered_repository) # todo: test?
      end
    end

    def search(arg)
      raise "Nil argument" if arg.nil?
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
        # todo
      else
        raise "???"
      end
    end
    
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

        c = caller.detect{|line| line !~ /treasury/} || caller[1]
        c.gsub!("#{File.expand_path(File.dirname(RAILS_ROOT))}/", '') if defined?(RAILS_ROOT)
        ActiveRecord::Base.logger.info("#{klass.name} Repository hitting DB from #{c}")

        found_in_store = klass.find(:all, :conditions => ["id IN (?)", needed])
        if found_in_store.size != needed.size
          missing = (needed - found_in_store.map(&:id))
          ActiveRecord::Base.logger.warn "Warning: couldn't find #{missing.size} out of #{needed.size} #{klass.name.pluralize}: missing #{missing.join(',')}"
        end
        put(found_in_store)
      end
      ids.map{|id| @stash[id]} # find again so they come back in order
    end
    
    def [](id)
      objects = search(id)
      if objects.empty?
        nil
      else
        objects.first
      end
    end

  end
end
