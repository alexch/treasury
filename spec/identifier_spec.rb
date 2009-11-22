require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

require 'activerecord'

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

module Treasury
  describe Identifier do
    describe 'new?' do
      it "works on a new ActiveRecord object" do
        Identifier.new?(ActiveUser.new).should be_true
      end
      it "works on a saved ActiveRecord object" do
        Identifier.new?(ActiveUser.create).should be_false
      end
      it "works on a new Treasure" do
        Identifier.new?(User.new).should be_true
      end
      it "works on a new Treasure" do
        user = User.new(:id => 1)
        Identifier.new?(user).should be_false
      end
    end

    describe 'id' do
      it "works on a new ActiveRecord object" do
        Identifier.id(ActiveUser.new).should be_nil
      end
      it "works on a saved ActiveRecord object" do
        Identifier.id(ActiveUser.create).should_not be_nil
      end
      it "works on a new Treasure" do
        Identifier.id(User.new).should be_nil
      end
      it "works on a new Treasure" do
        user = User.new(:id => 1)
        Identifier.id(user).should == 1
      end
    end
  end
end

