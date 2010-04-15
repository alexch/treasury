here = File.dirname(__FILE__)
require File.expand_path("#{here}/spec_helper")

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


    describe "individual criteria" do
      before do
        @repository = Repository.new(User)
      end

      def crit(&block)
        @repository.criterion_from &block
      end

      it "equals" do
        crit do |user|
          user.equals('name', 'alice')
        end.should == Criterion::Equals.new(:subject => "name", :value => "alice")
      end

      it "key" do
        crit do |user|
          user.key(99)
        end.should == Criterion::Key.new(:value => 99)
      end

      it "contains" do
        crit do |user|
          user.contains("name", "foo")
        end.should == Criterion::Contains.new(:subject => "name", :value => "foo")
      end

      it "refers_to" do
        crit do |user|
          user.refers_to("project_id", 32, Project)
        end.should == Criterion::RefersTo.new(:subject => "project_id", :value => 32, :referent_class => Project)
      end

      it "joins"
    end

    describe "conjunctions" do

      it "and"

      it "or"
    end


  end


end
