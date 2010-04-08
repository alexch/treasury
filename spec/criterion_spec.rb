here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"

module Treasury
  describe Criterion do
    before do
      @alice = User.new(:name => "Alice", :id => 1)
      @bob = User.new(:name => "Bob", :id => 2)
      @charlie = User.new(:name => "Charlie", :id => 3)
    end

    it "has some fields" do
      c = Criterion.new(:subject => "name", :descriptor => "is named", :value => "alex", :property_name => "nombre")
      c.subject.should == "name"
      c.descriptor.should == "is named"
      c.value.should == "alex"
      c.property_name.should == "nombre"
    end
    
    it 'should be equal if the instance variables are equivalent' do
      c1 = Criterion.new(:subject => "name", :descriptor => "is named", :value => "alex", :property_name => "nombre")
      c2 = Criterion.new(:subject => "name", :descriptor => "is named", :value => "alex", :property_name => "nombre")
      c1.should == c2
    end

    it "has some default values" do
      c = Criterion.new(:value => "123")
      c.subject.should == "id"
      c.descriptor.should == "id criterion"
      c.value.should == "123"
      c.property_name.should == "id"
    end

    it "converts a missing value into 'nil'" do
      c = Criterion.new({})
      c.value.should be_nil
    end

    it "converts a blank value into 'nil'" do
      c = Criterion.new({:value => ""})
      c.value.should be_nil
    end

    it "uses the subject as the property name by default" do
      c = Criterion.new(:subject => "name", :value => "alex")
      c.property_name.should == "name"
    end

    it "converts the subject to a string" do
      c = Criterion.new(:subject => :name, :value => "alex")
      c.subject.should == "name"
    end

    it "makes a nice description" do
      c = Criterion.new(:subject => "name", :descriptor => "is named", :value => "alex")
      c.description.should == "is named alex"
    end

    describe "operator overloading" do
      before do
        @c1 = Criterion::Equals.new(:subject => "name", :value => "alex")
        @c2 = Criterion::Equals.new(:subject => "name", :value => "kane")
      end
      
      it 'generates an And criterion when used with +' do
        c3 = @c1 + @c2
        c3.class.should == Criterion::And
        c3.criteria.should == [@c1, @c2]
      end

      it 'generates an And criterion when used with &' do
        c3 = @c1 & @c2
        c3.class.should == Criterion::And
        c3.criteria.should == [@c1, @c2]
      end

      it 'generates an Or criterion when used with |' do
        c3 = @c1 | @c2
        c3.class.should == Criterion::Or
        c3.criteria.should == [@c1, @c2]
      end
    end

    describe '#match' do
      it "matches nothing (since it's a base class)" do
        c = Criterion.new(:subject => "name", :value => "alex")
        c.match?(User.new(:name => "alex")).should be_false
      end
    end

    describe '#described_value' do
      it "describes its value" do
        c = Criterion.new(:value => "123")
        c.described_value.should == "123"
      end

      it "returns 'any' if the criterion is not set" do
        Criterion.new(:value => nil).described_value.should == 'any'
      end

      it "returns 'any' if the criterion is blank" do
        Criterion.new(:value => "").described_value.should == 'any'
      end

      it "returns 'none' if the criterion is zero" do
        Criterion.new(:value => 0).described_value.should == 'none'
      end
    end

    describe '#find_in'  do
      it "calls the storage" do
        c = Criterion.new(:value => nil)
        storage = Object.new
        storage.should_receive(:find).with(c)
        c.find_in(storage)
      end
    end

  end
end
