here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"

module Treasury
  describe Criterion do
    before do
      @alice = User.new(:name => "Alice", :id => 1)
      @bob = User.new(:name => "Bob", :id => 2)
      @charlie = User.new(:name => "Charlie", :id => 3)
    end

    describe Criterion::ExtractKeys do
      before do
        Treasury[User].store [@alice, @bob, @charlie]
        @nested_criterion = Criterion::Contains.new(:subject => "name", :value => "a")
      end

      it "performs a search and extracts the keys from its results" do
        Treasury[User].search(@nested_criterion).should include_only(@alice, @charlie)
        c = Criterion::ExtractKeys.new(:criterion => @nested_criterion)
        Treasury[User].search(c).should include_only(@alice.id, @charlie.id)
      end

      it "can be used as the target of an Equals criterion" do
        @chez_alice = Address.new(:user_id => @alice.id, :street => "12 Apple St.")
        @chez_bob = Address.new(:user_id => @bob.id, :street => "28 Banana St.")
        @chez_charlie = Address.new(:user_id => @charlie.id, :street => "42 Cherry St.")

        Treasury[Address].store [@chez_alice, @chez_bob, @chez_charlie]

        user_ids = Criterion::ExtractKeys.new(:criterion => @nested_criterion)
        user_search = Treasury[User].search(user_ids)  # todo: make each criterion class-aware so the searches can be nested
        addresses = Treasury[Address].search(Criterion::Key.new(:subject => :user_id, :value => user_search))

        addresses.should == [@chez_alice, @chez_charlie]
      end
    end

  end
end
