here = File.dirname(__FILE__)
require File.expand_path("#{here}/spec_helper")

=begin
Repository needs to
* take a list of objects with keys and stash theme
* take a (class and a) list of keys and retrieve them from the stash only
* when given a list of keys, it asks the storage for the unfound remainder
* when asking the storage for anything, it stashes them on the way back
* the stash should expire old items based on some algorithm
* take a query and retrieve them from the stash only
* take a query and retrieve them from the storage only (but stash them on the way back)
* chain queries, e.g. "get all addresses for all users whose zip is 90210"
* storage a list of items, replacing what's in the stash too
* deal with relationships

Storage needs to
* query

Query/Criteria needs to
* ...
* run? or does a repository run a query?

other features:
* define a query with a DSL
* "has_many" mixin
* different storages for different classes

=end

module Treasury
  describe Repository do
    attr_reader :frank, :igor, :brain, :lunch
    attr_reader :repository

    before do
      @frank = User.new(:name => "frankenstein")
      @igor = User.new(:name => "igor")
      @elsa = User.new(:name => "elsa")

      @castle = Address.new()
      @old_logger = ActiveRecord::Base.logger
      @output = StringIO.new
      ActiveRecord::Base.logger = Logger.new(@output)

      @repository = Repository.new(User)

      Treasury.clear_all
    end

    after do
      ActiveRecord::Base.logger = @old_logger
    end
    
    def args_for_finding(array)
      [:all, {:conditions => ["id IN (?)", array]}]
    end

    it "is empty when created" do
      repository.size.should == 0
    end

    it "has a size after an object's been put into it" do
      repository.store(frank)
      repository.size.should == 1
    end

    describe "#clear" do
      it "clears" do
        repository.store(frank)
        repository.clear
        repository.size.should == 0
      end
    end

    describe "#put" do
      it "saves a new record before sticking it in the repository" do
        frank.id.should be_nil
        repository.store(frank)
        frank.id.should_not be_nil
        repository[frank.id].should == frank
      end

      it "saves several new records" do
        repository.store([frank, igor])
        frank.id.should_not be_nil
        igor.id.should_not be_nil
      end

      it "accepts an array of objects" do
        repository.store([frank, igor])
        repository.size.should == 2
        repository[frank.id].should == frank
        repository[igor.id].should == igor
      end
      
      it "accepts an array of objects" do
        repository.store(frank, igor)
        repository.size.should == 2
        repository[frank.id].should == frank
        repository[igor.id].should == igor
      end

      it "freaks if you try to put an object of the wrong type" do
        lambda do
          repository.store(@castle)
        end.should raise_error(ArgumentError)
      end
      
      class Animal
        def id; 1; end
      end

      class Dog < Animal
        def id; 2; end
      end

      class Cat < Animal
        def id; 3; end
      end

      it "doesn't freak if you put an object that's a subclass of the repository's type" do
        lambda do
          repository = Repository.new(Animal)
          repository.store(Dog.new)
          repository.store(Cat.new)
        end.should_not raise_error(ArgumentError)
      end
    end

    describe '#[]' do
      it "returns a single object" do
        repository.store(frank)
        repository[frank.id].should == frank
      end

      it "returns nil and warns if nothing found" do
        # User.should_receive(:find).with(*args_for_finding([99])).and_return([])
        repository[99].should == nil
        @output.string.should =~ /Treasury::User Repository hitting storage from/
        @output.string.should =~ /Warning: couldn't find 1 out of 1 Treasury::Users: missing keys 99/
      end

      it "finds an object by string id" do
        repository.store(frank)
        repository.search("#{frank.id}").should == [frank]
      end
    end

    describe "#search" do
      it "returns an array of objects" do
        repository.store(frank)
        x = repository.search(frank.id)
        x.should_not be_nil
        x.should == [frank]
        repository[frank.id].should == frank
      end

      it "returns several objects" do
        repository.store(frank)
        repository.store(igor)
        repository.search([frank.id, igor.id]).should == [frank, igor]
      end

      it "returns them in the presented order" do
        repository.store(frank)
        repository.store(igor)
        repository.search([igor.id, frank.id]).should == [igor, frank]
      end

      it "finds an object by id and stores it immediately" do
        repository.storage.store(frank)
        repository.search(frank.id).should == [frank]
        repository.size.should == 1
        repository[frank.id].should == frank
      end

      it "finds an object by string id" do
        repository.store(frank)
        repository.search("#{frank.id}").should == [frank]
      end

      it "finds a bunch of objects and stores them immediately" do
        repository.store([frank, igor])
        repository.search([frank.id, igor.id]).should == [frank, igor]
        repository.size.should == 2
        repository[frank.id].should == frank
        repository[igor.id].should == igor
      end

      it "doesn't ask ActiveRecord to find objects if they're already in the repository" do
        repository.store(frank)
        repository.storage.store(igor)
        repository.search([frank.id, igor.id]).should == [frank, igor]
        @output.string.should =~ /Treasury::User Repository hitting storage from/
      end

      it "returns them in the presented order" do
        repository.store([frank, igor])
        repository.search([frank.id, igor.id]).should == [frank, igor]
        repository.search([igor.id, frank.id]).should == [igor, frank]
      end

      it "works ok even if there are duplicate keys" do
        repository.store([frank, igor])
        repository.search([frank.id, igor.id, frank.id, frank.id, igor.id]).should == [frank, igor, frank, frank, igor]
      end

      it "only requests unique keys from storage if there are duplicate keys" do
        frank.save!
        igor.save!
        repository.storage.should_receive(:find_by_keys).with([frank.id, igor.id]).and_return([frank, igor])
        repository.search([frank.id, igor.id, frank.id, frank.id, igor.id]).should == [frank, igor, frank, frank, igor]
        @output.string.should =~ /Treasury::User Repository hitting storage from/
      end

      it "finds by criterion, and stashes the results for later" do
        repository.storage.store(frank)
        repository.size.should == 0
        criterion = Criterion::Equals.new(:subject => "name", :value => frank.name)
        repository.search(criterion).should == [frank]
        repository.size.should == 1
        repository.instance_variable_get(:@stash).get(frank.id).should == frank
      end

      # see dsl_spec for more
      it "accepts a block which uses the factory DSL" do
        repository.storage.store(frank)
        repository.search do |q|
          q.equals('name', frank.name)
        end.should == [frank]        
      end

      it 'fails if neither an argument nor a block is passed' do
        lambda do
          repository.search
        end.should raise_error
      end
      
      it 'fails if both an argument and a block are passed' do
        lambda do
          repository.search(99) do |factory|
          end
        end.should raise_error
      end
    end
    
    describe '#extract' do
      before do
        @repository.store([@frank, @igor, @elsa])
      end

      it 'performs a search and pulls out the keys' do
        criterion = Criterion::Contains.new(:subject => "name", :value => "a")
        @repository.extract(criterion).should include_only(@frank.id, @elsa.id)
      end

      it 'performs a search with a block and pulls out the keys' do
        @repository.extract do |user|
          user.contains(:name,  "a")
        end.should include_only(@frank.id, @elsa.id)
      end
    end

    describe '#find_keys_in_criterion' do
      it "asks for the criterion's value" do
        criterion = Object.new
        criterion.should_receive(:value).and_return([99])
        @repository.send(:find_keys_in_criterion, criterion)
      end
    end
    
    describe '#criterion_from' do
      it 'accepts a block and passes it a factory' do
        criterion = repository.criterion_from do |criterion_factory|
          criterion_factory.equals('active', true)
        end
        criterion.should == Criterion::Equals.new(:subject => 'active', :value => true)
      end
    end

    class Dummy < Treasure
      attr_reader :entered
      def id
        1
      end
      def entered_repository
        @entered = true
      end
    end

    it "calls #entered_repository after put" do
      repo = Repository.new(Dummy)
      dummy = Dummy.new
      repo.store(dummy)
      dummy.entered.should be_true
    end

  end

end

