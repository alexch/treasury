here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"

module Treasury
  describe Criterion do
    before do
      @alice = User.new(:name => "Alice", :id => 1)
      @bob = User.new(:name => "Bob", :id => 2)
      @charlie = User.new(:name => "Charlie", :id => 3)
    end
    
    describe Criterion::Conjunction do
      it "nested criteria flatten out OK" do
        action_keys = [1,2,3]
        more_action_keys = [4,5,6]
        c = (Treasury::Criterion::Equals.new(:subject => 'active', :value => true) +
              (Treasury::Criterion::Key.new(:subject => 'upstream_action_id', :value => action_keys) |
               Treasury::Criterion::Key.new(:subject => 'downstream_action_id', :value => more_action_keys)))
        c.sql.should ==
         ["(active = ?) AND ((upstream_action_id IN (?)) OR (downstream_action_id IN (?)))", true, action_keys, more_action_keys]
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
