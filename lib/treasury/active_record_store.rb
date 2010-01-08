module Treasury
  class ActiveRecordStore < Store

    def self.key_for(object)
      object.id
    end
    
    def self.new?(object)
      object.new_record?
    end

    def size
      @klass.count
    end

    def clear
      @klass.delete_all
    end

    def put_old(objects)
      objects.each do |o|
        o.save!
      end
    end

    def put_new(objects)
      put_old(objects)
    end

    def find_by_ids(ids)
      @klass.find(:all, :conditions => ["id IN (?)", ids])
    end

    def find_by_criterion(criterion)
      @klass.find(:all, :conditions => criterion.sql)
    end

  end
  
  Identifier.register(ActiveRecord::Base, ActiveRecordStore)
end
