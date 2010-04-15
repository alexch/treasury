require 'ostruct'

module Treasury

  class Treasure
    attr_accessor :id, :entered_repository

    def treasury_key
      id
    end

    def initialize(hash = {})
      {:id => nil}.merge(hash).each_pair do |k,v|
        self.class.class_eval do
          attr_accessor k.to_sym
        end
        instance_variable_set("@#{k}", v)
      end
    end

    def save!
      unless id
        @@next_id ||= 0
        @id = (@@next_id += 1)
      end
    end
    
  end

  class TreasureStorage < StashStorage
    def store_new(objects)
      objects.each do |object|
        object.save!
      end
      store_old(objects)
    end
  end
  
  Keymaster.register(Treasure, TreasureStorage)

  ###

  class Project < Treasure

  end
  
  class User < Treasure
    def initialize(hash = {})
      super({:name => nil}.merge(hash))
    end
  end

  class Address < Treasure
  end

  class Country < Treasure
  end


end
