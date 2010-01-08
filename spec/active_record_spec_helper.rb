require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)

class ActiveUser < ActiveRecord::Base
  
end

class CreateActiveUser < ActiveRecord::Migration
  def self.up
    create_table :active_users do |t|
      t.string :name
    end
  end
end

CreateActiveUser.up
