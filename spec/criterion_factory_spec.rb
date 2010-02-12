require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

module Treasury
  describe Criterion::Factory do
    it "builds with equals" do
      criterion = Criterion::Factory.equals('active', true)
      criterion.should == Criterion::Equals.new(:subject => 'active', :value => true)
    end
    
    it "builds with key and one argument" do
      criterion = Criterion::Factory.key(99)
      criterion.should == Criterion::Key.new(:subject => 'key', :value => 99)
    end
    
    it "builds with key and two arguments" do
      criterion = Criterion::Factory.key('address_id', 99)
      criterion.should == Criterion::Key.new(:subject => 'address_id', :value => 99)
    end
    
    it "converts a symbol into a string for the subject field name" do
      criterion = Criterion::Factory.key(:address_id, 99)
      criterion.should == Criterion::Key.new(:subject => 'address_id', :value => 99)
    end
  end
end
