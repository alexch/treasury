here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"

module Treasury
  describe Criterion do
    before do
      @alice = User.new(:name => "Alice", :id => 1)
      @bob = User.new(:name => "Bob", :id => 2)
      @charlie = User.new(:name => "Charlie", :id => 3)
    end

    describe Criterion::RefersTo do
      before do
        @c = Criterion::RefersTo.new(:subject => "user_id", :value => "7", :referent_class => User)
      end

      it "has a swell descriptor" do
        @c.descriptor.should == "user_id refers to"
      end

      # it "grabs the name from its referent in its description -- e.g. 'user is' or 'has user' instead of 'user_id refers to'"

      it "converts its value to an integer" do
        @c.value.should == 7
      end

      it "doesn't convert its value to an integer if it's nil" do
        Criterion::RefersTo.new(:value => nil).value.should be_nil
      end

      it "makes some bodacious sql" do
        @c.sql.should == ["user_id = ?", 7]
      end

      it "knows the class of its referent" do
        @c.referent_class.should == User
      end

      it "looks up its referent to get its described value" do
        mock_user = mock("User")
        mock_user.stub!(:name).and_return("YAY")
        Treasury[User].should_receive(:search).with(7).and_return(mock_user)
        @c.described_value.should == "YAY"
      end

      it "returns 'any' if the value is not set" do
        Criterion::RefersTo.new(:value => nil, :referent_class => User).described_value.should == 'any'
      end

      it "returns 'any' if the value is blank" do
        Criterion::RefersTo.new(:value => "", :referent_class => User).described_value.should == 'any'
      end

      it "returns 'none' if the criterion is zero" do
        Criterion::RefersTo.new(:value => 0, :referent_class => User).described_value.should == 'none'
      end

    end


  end
end
