here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"

module Treasury
  describe Criterion do
    before do
      @alice = User.new(:name => "Alice", :id => 1)
      @bob = User.new(:name => "Bob", :id => 2)
      @charlie = User.new(:name => "Charlie", :id => 3)
    end
    
    describe Criterion::Key do
      before do
        @c = Criterion::Key.new(:value => "1")
      end

      it "uses 'id' as its subject" do
        @c.subject.should == "id"
      end

      it "makes some nice sql" do
        @c.sql.should == ["id IN (?)", [1]]
      end

      it "uses IN if the value is an array" do
        @c = Criterion::Key.new(:value => [1,2,3])
        @c.sql.should == ["id IN (?)", [1,2,3]]
      end

      it "has a swell descriptor" do
        Criterion::Key.new({}).descriptor.should == "#"
      end

      it "converts its value to an integer" do
        @c.value.should == [1]
      end
      
      describe '#match' do
        it "matches an id" do
          @c.match?(@alice).should be_true
        end

        it "fails to match an id" do
          @c.match?(@bob).should be_false
        end

        describe "a set of ints" do
          before do
            @c = Criterion::Key.new(:value => [1,2])
          end

          it "matches" do
            @c.should be_match @alice
            @c.should be_match @bob
          end

          it "fails to match an int" do
            @c.should_not be_match @charlie          
          end
        end
      end

      describe "a string value in the criterion" do
        it "should match an int value in the object" do
          @c = Criterion::Key.new(:value => "1")
          @c.should be_match @alice            
        end
      end

    end

  end
end
