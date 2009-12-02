require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

module Treasury
  describe Criterion::Factory do
    it "builds with equals" do
      criterion = Criterion::Factory.equals('active', true)
      criterion.should == Criterion::Equals.new(:subject => 'active', :value => true)
    end
    
    it "builds with id and one argument" do
      criterion = Criterion::Factory.id(99)
      criterion.should == Criterion::Id.new(:subject => 'id', :value => 99)
    end
    
    it "builds with id and two arguments" do
      criterion = Criterion::Factory.id('address_id', 99)
      criterion.should == Criterion::Id.new(:subject => 'address_id', :value => 99)
    end
    
    it "converts a symbol into a string for the subject field name" do
      criterion = Criterion::Factory.id(:address_id, 99)
      criterion.should == Criterion::Id.new(:subject => 'address_id', :value => 99)
    end
  end
end
