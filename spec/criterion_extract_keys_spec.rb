here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"

module Treasury
  describe Criterion::ExtractKeys do
    before do
      [Treasury[User], Treasury[Address]].each do |repository|
        repository.clear
        repository.storage.clear
      end

      Treasury[Address].size.should == 0
      Treasury[Address].storage.size.should == 0

      @alice = User.new(:name => "Alice")
      @bob = User.new(:name => "Bob")
      @charlie = User.new(:name => "Charlie")
      Treasury[User].store [@alice, @bob, @charlie]

      @chez_alice = Address.new(:user_id => @alice.id, :street => "12 Apple St.")
      @chez_alice2 = Address.new(:user_id => @alice.id, :street => "8 Artichoke Ave.")
      @chez_bob = Address.new(:user_id => @bob.id, :street => "28 Banana St.")
      @chez_charlie = Address.new(:user_id => @charlie.id, :street => "42 Cherry St.")
      Treasury[Address].store [@chez_alice, @chez_alice2, @chez_bob, @chez_charlie]

      @nested_criterion = Criterion::Contains.new(:subject => "name", :value => "a")
      @extractor = Criterion::ExtractKeys.new(:referent_class => User, :criterion => @nested_criterion)
    end

    describe 'the nested criterion' do
      it "should find only 2 out of the 3 users" do
        Treasury[User].search(@nested_criterion).should include_only(@alice, @charlie)
      end
    end

    it "knows the class of its referent" do
      @extractor.referent_class.should == User
    end

    it "when used to perform a search, extracts the keys from its results" do
      Treasury[User].search(@extractor).should include_only(@alice.id, @charlie.id)
    end

    describe '#value' do
      it "executes a nested search" do
        @extractor.value.should include_only(@alice.id, @charlie.id)
      end
    end

    it "can be used as the target of an Equals criterion" do
      straight_id_criterion = Criterion::Equals.new(:subject => :user_id, :value => [@alice.id, @charlie.id])
      addresses = Treasury[Address].search(straight_id_criterion)
      addresses.should == [@chez_alice, @chez_alice2, @chez_charlie]

      addresses_criterion = Criterion::Equals.new(:subject => :user_id, :value => @extractor)
      addresses = Treasury[Address].search(addresses_criterion)
      addresses.should == [@chez_alice, @chez_alice2, @chez_charlie]
    end
  end

end
