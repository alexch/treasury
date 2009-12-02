require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

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
    
    describe Criterion::Id do
      before do
        @c = Criterion::Id.new(:value => "1")
      end

      it "uses 'id' as its subject" do
        @c.subject.should == "id"
      end

      it "makes some nice sql" do
        @c.sql.should == ["id IN (?)", [1]]
      end

      it "uses IN if the value is an array" do
        @c = Criterion::Id.new(:value => [1,2,3])
        @c.sql.should == ["id IN (?)", [1,2,3]]
      end

      it "has a swell descriptor" do
        Criterion::Id.new({}).descriptor.should == "#"
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
            @c = Criterion::Id.new(:value => [1,2])
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
          @c = Criterion::Id.new(:value => "1")
          @c.should be_match @alice            
        end
      end

    end

    describe Criterion::Equals do
      before do
        @c = Criterion::Equals.new(:subject => "name", :value => "alex")
      end

      it "makes some nice sql" do
        @c.sql.should == ["name = ?", "alex"]
      end

      it "uses IN if the value is an array" do
        @c = Criterion::Equals.new(:subject => "id", :value => [1,2,3])
        @c.sql.should == ["id IN (?)", [1,2,3]]
      end

      it "has a swell descriptor" do
        Criterion::Equals.new({}).descriptor.should == "id equals"
      end

      describe '#match' do
        describe "a string" do
          before do
            @c = Criterion::Equals.new(:subject => "name", :value => "Alice")
          end

          it "matches a string" do
            @c.should be_match @alice
          end

          it "fails to match a string" do
            @c.should_not be_match @bob
          end

          it "fails to match a string with the wrong case" do
            @c.should_not be_match User.new(:name => "alice")
          end
        end

        describe "an int" do
          before do
            @c = Criterion::Equals.new(:subject => "id", :value => 1)
          end

          it "matches an int" do
            @c.match?(@alice).should be_true
          end

          it "fails to match an int" do
            @c.match?(@bob).should be_false
          end
        end

        describe "a set of ints" do
          before do
            @c = Criterion::Equals.new(:subject => "id", :value => [1,2])
          end

          it "matches" do
            @c.should be_match @alice
            @c.should be_match @bob
          end

          it "fails to match an int" do
            @c.should_not be_match @charlie          
          end
        end
        
        describe "a string value in the criterion" do
          it "should match an int value in the object" do
            @c = Criterion::Equals.new(:subject => "id", :value => "1")
            @c.should be_match @alice            
          end
        end

      end
    end

    describe Criterion::Contains do
      before do
        @c = Criterion::Contains.new(:subject => "name", :value => "ABC")      
      end

      it "has a swell descriptor" do
        @c.descriptor.should == "name contains"
      end

      it "makes some yummy sql" do
        @c.sql.should == ["LOWER(name) LIKE ?", "%abc%"]
      end
      it "matches identical text" do
        @c.should be_match(User.new(:name => "ABC"))
      end
      it "matches mixed-case identical text" do
        @c.should be_match(User.new(:name => "AbC"))
      end
      it "matches text in the middle" do
        @c.should be_match(User.new(:name => "drabCouch"))
      end
      it "doesn't match different text" do
        @c.should_not be_match(User.new(:name => "abx"))
      end
      describe "multiple values" do
        before do
          @c = Criterion::Contains.new(:subject => "name", :descriptor => "is kinda named", :value => ["ABC", "123"])
        end
        it "matches any" do
          @c.should be_match(User.new(:name => "abc"))
          @c.should be_match(User.new(:name => "123"))
        end
        it "fails to match" do
          @c.should_not be_match(User.new(:name => "12ab3c"))
        end
      end
    end

    describe Criterion::RefersTo do
      before do
        @c = Criterion::RefersTo.new(:subject => "user_id", :value => "7", :referent_class => User)
      end

      it "has a swell descriptor" do
        @c.descriptor.should == "user_id refers to"  #todo: "user is" or "has user"
      end

      it "grabs the name from its referent in its description"

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

    describe Criterion::And do
      before do
        @c = Criterion::And.new(
          (@c1 = Criterion::Contains.new(:subject => "name", :value => "a")),
          (@c2 = Criterion::Contains.new(:subject => "name", :value => "r"))
        )
      end
      
      describe '#match' do

        it "fails to match if no criteria match" do
          @c.should_not be_match(@bob)
        end

        it "fails to match if only one criterion matches" do
          @c.should_not be_match(@alice)
        end

        it "matches if all criteria match" do
          @c.should be_match(@charlie)
        end
      end

      describe '#sql' do
        it "ANDs the sub-criteria's sql" do
          @c.sql.should == ["(#{@c1.sql[0]}) AND (#{@c2.sql[0]})", "%a%", "%r%"]
        end

        it "doesn't say AND if there's only one contained criterion" do
          c = Criterion::Equals.new(:subject => "pet", :value => "gerbil")
          sql_parts = c.sql
          sql_parts[0] = "(#{sql_parts[0]})"
          Criterion::And.new(c).sql.should == sql_parts
        end
      end
    end
    
    describe Criterion::Or do
      before do
        @c = Criterion::Or.new(
          (@c1 = Criterion::Contains.new(:subject => "name", :value => "o")),  # 'o' is only in 'bob'
          (@c2 = Criterion::Contains.new(:subject => "name", :value => "r"))   # 'r' is only in 'charlie'
        )
      end

      describe '#match' do

        it "fails to match if no criteria match" do
          @c.should_not be_match(@alice)
        end

        it "matches if only one criterion matches" do
          @c.should be_match(@bob)
          @c.should be_match(@charlie)
        end
      end

      describe '#sql' do
        it "ORs the sub-criteria's sql" do
          @c.sql.should == ["(#{@c1.sql[0]}) OR (#{@c2.sql[0]})", "%o%", "%r%"]
        end

        it "doesn't say OR if there's only one contained criterion" do
          c = Criterion::Equals.new(:subject => "pet", :value => "gerbil")
          sql_parts = c.sql
          sql_parts[0] = "(#{sql_parts[0]})"
          Criterion::Or.new(c).sql.should == sql_parts
        end
      end
      
    end
    
  end
end