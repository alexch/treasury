begin
  require 'activerecord' # todo: make optional
rescue LoadError
  require 'rubygems'
  require 'activerecord'
end

module Treasury
  class Identifier
    def self.new?(object)
      case object
      when ActiveRecord::Base
        object.new_record?
      else
        object.id.nil?
      end
    end
    
    def self.id(object)
      case object
      when ActiveRecord::Base
        if object.new_record?
          nil
        else
          object.id
        end
      else
        object.id
      end
    end
  end
end

