here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"

module Treasury
  describe Criterion do
    before do
      @alice = User.new(:name => "Alice", :id => 1)
      @bob = User.new(:name => "Bob", :id => 2)
      @charlie = User.new(:name => "Charlie", :id => 3)
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

  end
end
