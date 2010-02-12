here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"
require  "#{here}/active_record_spec_helper"

module Treasury
  describe Keymaster do
    it 'can look up the store for an object by its class' do
      Keymaster.store_for(ActiveUser.new).should == ActiveRecordStore
      Keymaster.store_for(User.new).should == TreasureStore
    end
    
    describe 'register' do
      class Unobtainium
      end
      class UnobtainiumStore < Store
      end
      it 'inserts a store into the registry' do
        object = Unobtainium.new
        lambda { Keymaster.store_for(object) }.should raise_error
        Keymaster.register(Unobtainium, UnobtainiumStore)
        Keymaster.store_for(object).should == UnobtainiumStore
      end
    end
    
    describe 'new?' do
      it "works on a new ActiveRecord object" do
        Keymaster.new?(ActiveUser.new).should be_true
      end
      it "works on a saved ActiveRecord object" do
        Keymaster.new?(ActiveUser.create).should be_false
      end
      it "works on a new Treasure" do
        Keymaster.new?(User.new).should be_true
      end
      it "works on a new Treasure" do
        user = User.new(:id => 1)
        Keymaster.new?(user).should be_false
      end
    end

    describe 'key_for' do
      it "works on a new ActiveRecord object" do
        Keymaster.key_for(ActiveUser.new).should be_nil
      end
      it "works on a saved ActiveRecord object" do
        Keymaster.key_for(ActiveUser.create).should_not be_nil
      end
      it "works on a new Treasure" do
        Keymaster.key_for(User.new).should be_nil
      end
      it "works on a new Treasure" do
        user = User.new(:id => 1)
        Keymaster.key_for(user).should == 1
      end
    end
  end
end

