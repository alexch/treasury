here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"
require  "#{here}/active_record_spec_helper"

module Treasury
  describe Identifier do
    it 'can look up the store for an object by its class' do
      Identifier.store_for(ActiveUser.new).should == ActiveRecordStore
      Identifier.store_for(User.new).should == TreasureStore
    end
    
    describe 'register' do
      class Unobtainium
      end
      class UnobtainiumStore < Store
      end
      it 'inserts a store into the registry' do
        object = Unobtainium.new
        lambda { Identifier.store_for(object) }.should raise_error
        Identifier.register(Unobtainium, UnobtainiumStore)
        Identifier.store_for(object).should == UnobtainiumStore
      end
    end
    
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

    describe 'key_for' do
      it "works on a new ActiveRecord object" do
        Identifier.key_for(ActiveUser.new).should be_nil
      end
      it "works on a saved ActiveRecord object" do
        Identifier.key_for(ActiveUser.create).should_not be_nil
      end
      it "works on a new Treasure" do
        Identifier.key_for(User.new).should be_nil
      end
      it "works on a new Treasure" do
        user = User.new(:id => 1)
        Identifier.key_for(user).should == 1
      end
    end
  end
end

