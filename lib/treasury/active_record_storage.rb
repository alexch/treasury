module Treasury
  class ActiveRecordStorage < Storage

    def self.key_for(object)
      object.id
    end
    
    def self.new?(object)
      object.new_record?
    end
    
    def initialize(klass)
      raise "whoa" unless klass
      super
    end

    def size
      @klass.count
    end

    def clear
      @klass.delete_all
    end

    def store_old(objects)
      objects.each do |o|
        o.save!
      end
    end

    def store_new(objects)
      store_old(objects)
    end

    def find_by_keys(keys)
      @klass.find(:all, :conditions => ["id IN (?)", keys])
    end

    def find_by_criterion(criterion)
      @klass.find(:all, :conditions => criterion.sql)
    end

  end
  
  Keymaster.register(ActiveRecord::Base, ActiveRecordStorage)
end
