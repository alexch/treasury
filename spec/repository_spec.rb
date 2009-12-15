require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

=begin
Repository needs to
* take a list of objects with ids and stash theme
* take a (class and a) list of ids and retrieve them from the stash only
* when given a list of ids, it asks the store for the unfound remainder
* when asking the store for anything, it stashes them on the way back
* the stash should expire old items based on some algorithm
* take a query and retrieve them from the stash only
* take a query and retrieve them from the store only (but stash them on the way back)
* chain queries, e.g. "get all addresses for all users whose zip is 90210"
* store a list of items, replacing what's in the stash too
* deal with relationships

Store needs to
* query

Query/Criteria needs to
* ...
* run? or does a repository run a query?

other features:
* define a query with a DSL
* "has_many" mixin
* different stores for different classes

=end

module Treasury 
  describe Repository do
    attr_reader :frank, :igor, :brain, :lunch
    attr_reader :repository

    before do
      @frank = User.new(:name => "frankenstein")
      @igor = User.new(:name => "igor")

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
      repository.put(frank)
      repository.size.should == 1
    end

    describe "#clear" do
      it "clears" do
        repository.put(frank)
        repository.clear
        repository.size.should == 0
      end
    end

    describe "#put" do
      it "saves a new record before sticking it in the repository" do
        frank.id.should be_nil
        repository.put(frank)
        frank.id.should_not be_nil
        repository[frank.id].should == frank
      end

      it "saves several new records" do
        repository.put([frank, igor])
        frank.id.should_not be_nil
        igor.id.should_not be_nil
      end

      it "accepts an array of objects" do
        repository.put([frank, igor])
        repository.size.should == 2
        repository[frank.id].should == frank
        repository[igor.id].should == igor
      end
      
      it "accepts an array of objects" do
        repository.put(frank, igor)
        repository.size.should == 2
        repository[frank.id].should == frank
        repository[igor.id].should == igor
      end

      it "freaks if you try to put an object of the wrong type" do
        lambda do
          repository.put(@castle)
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
          repository.put(Dog.new)
          repository.put(Cat.new)
        end.should_not raise_error(ArgumentError)
      end
    end

    describe '#[]' do
      it "returns a single object" do
        repository.put(frank)
        repository[frank.id].should == frank
      end

      it "returns nil and warns if nothing found" do
        User.should_receive(:find).with(*args_for_finding([99])).and_return([])
        repository[99].should == nil
        @output.string.should =~ /Treasury::User Repository hitting DB from/
        @output.string.should =~ /Warning: couldn't find 1 out of 1 Treasury::Users: missing ids 99/
      end

      it "finds an object by string id" do
        repository.put(frank)
        repository.search("#{frank.id}").should == [frank]
      end

    end

    describe "#search" do
      it "returns an array of objects" do
        repository.put(frank)
        x = repository.search(frank.id)
        x.should_not be_nil
        x.should == [frank]
        repository[frank.id].should == frank
      end

      it "returns several objects" do
        repository.put(frank)
        repository.put(igor)
        repository.search([frank.id, igor.id]).should == [frank, igor]
      end

      it "returns them in the presented order" do
        repository.put(frank)
        repository.put(igor)
        repository.search([igor.id, frank.id]).should == [igor, frank]
      end

      it "finds an object by id and puts it immediately" do
        frank.save!
        User.should_receive(:find).with(*args_for_finding([frank.id])).and_return([frank])
        repository.search(frank.id).should == [frank]
        repository.size.should == 1
        repository[frank.id].should == frank
        @output.string.should =~ /Treasury::User Repository hitting DB from/
      end

      it "finds an object by string id" do
        repository.put(frank)
        repository.search("#{frank.id}").should == [frank]
      end

      it "finds a bunch of objects and puts them immediately" do
        repository.put([frank, igor])
        repository.search([frank.id, igor.id]).should == [frank, igor]
        repository.size.should == 2
        repository[frank.id].should == frank
        repository[igor.id].should == igor
      end

      it "doesn't ask ActiveRecord to find objects if they're already in the repository" do
        repository.put(frank)
        igor.save!
        User.should_receive(:find).with(*args_for_finding([igor.id])).and_return([igor])
        repository.search([frank.id, igor.id]).should == [frank, igor]
        @output.string.should =~ /Treasury::User Repository hitting DB from/
      end

      it "returns them in the presented order" do
        repository.put([frank, igor])
        repository.search([frank.id, igor.id]).should == [frank, igor]
        repository.search([igor.id, frank.id]).should == [igor, frank]
      end

      it "works ok even if there are duplicate ids" do
        repository.put([frank, igor])
        repository.search([frank.id, igor.id, frank.id, frank.id, igor.id]).should == [frank, igor, frank, frank, igor]
      end

      it "only sends unique ids to ActiveRecord if there are duplicate ids" do
        frank.save!
        igor.save!
        User.should_receive(:find).with(*args_for_finding([frank.id, igor.id])).and_return([frank, igor])
        repository.search([frank.id, igor.id, frank.id, frank.id, igor.id]).should == [frank, igor, frank, frank, igor]
        @output.string.should =~ /Treasury::User Repository hitting DB from/
      end

      it "finds by criterion, and stashes the results for later" do
        repository.size.should == 0
        User.should_receive(:find).with(:all, {:conditions => ["name = ?", frank.name]}).and_return([frank])
        repository.search(Criterion::Equals.new(:subject => "name", :value => frank.name)).should == [frank]
        repository.size.should == 1
        repository.instance_variable_get(:@stash).get(frank.id).should == frank
      end
      
      it "accepts a block which uses the factory DSL" do
        User.should_receive(:find).with(:all, {:conditions => ["name = ?", frank.name]}).and_return([frank])
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
    
    describe '#criterion_from' do
      it 'accepts a block and passes it a factory' do
        criterion = repository.criterion_from do |criterion_factory|
          criterion_factory.equals('active', true)
        end
        criterion.should == Criterion::Equals.new(:subject => 'active', :value => true)
      end
    end

    class Dummy
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
      repo.put(dummy)
      dummy.entered.should be_true
    end

  end

end

