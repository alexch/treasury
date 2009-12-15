require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")
module Treasury
  describe Stash do
    include Matchers
    
    before do
      @frank = User.new(:name => "Frankenstein", :id => 1)
      @igor = User.new(:name => "Igor", :id => 2)
      @castle = Address.new(:name => "find a brain", :creator => @frank, :id => 1)
      @village = Address.new(:name => "buy lunch", :creator => @igor, :id => 2)
    end

    attr_reader :stash
    
    before do
      @stash = Stash.new
    end

    it "is empty when created" do
      stash.size.should == 0
    end

    it "fails if you try to put an object without a id" do
      lambda { stash.put(User.new) }.should raise_error(Store::Unidentified)
    end

    it "has a size after an object's been put into it" do
      stash.put(@frank)
      stash.size.should == 1
    end

    describe "#clear" do
      it "clears" do
        stash.put(@frank)
        stash.clear
        stash.size.should == 0
      end
    end

    describe "#get" do
      it "returns an object by id" do
        stash.put(@frank)
        stash.get(@frank.id).should == @frank
        stash[@frank.id].should == @frank
      end

      # it "returns several objects" do
      #   stash.put(@frank)
      #   stash.put(igor)
      #   stash.get([@frank.id, igor.id]).should == [@frank, igor]
      # end
      # 
      # it "returns them in the presented order" do
      #   stash.put(@frank)
      #   stash.put(igor)
      #   stash.get([igor.id, @frank.id]).should == [igor, @frank]
      # end

    end

    describe "#put" do
      it "accepts an array of objects" do
        stash.put([@frank, @igor])
        stash.size.should == 2
        stash[@frank.id].should == @frank
        stash[@igor.id].should == @igor
      end
    # 
    #   it "freaks if you try to put an object of the wrong type" do
    #     lambda {
    #       stash.put(brain)
    #       }.should raise_error(ArgumentError)
    #     end
    # 
    #     class Animal
    #       def id; 1; end
    #     end
    # 
    #     class Dog < Animal
    #       def id; 2; end
    #     end
    # 
    #     class Cat < Animal
    #       def id; 3; end
    #     end
    # 
    #     it "doesn't freak if you put an object that's a subclass of the stash's type" do
    #       lambda {
    #         stash = Stash.new(Animal)
    #         stash.put(Dog.new)
    #         stash.put(Cat.new)
    #         }.should_not raise_error(ArgumentError)
    #       end
    # 
    #       class Dummy
    #         attr_reader :entered
    #         def id
    #           1
    #         end
    #         def entered_stash
    #           @entered = true
    #         end
    #       end
    # 
    #       it "calls #entered_stash after put" do
    #         repo = Stash.new(Dummy)
    #         dummy = Dummy.new
    #         repo.put(dummy)
    #         dummy.entered.should be_true
    #       end
    # 
    end

        describe "#find" do
          before do
            stash.put(@frank)
            stash.put(@igor)
          end
          
          it "finds an object by an array of ids" do
            stash.find([@frank.id, @igor.id]).should include_only [@frank, @igor]
          end

          it "finds an object by a criterion on id" do
            stash.find(Criterion::Equals.new(:value => @frank.id)).should == [@frank]
          end

          it "finds an object by a criterion on a value" do
            stash.find(Criterion::Contains.new(:subject => "name", :value => "gor")).should == [@igor]
          end

    #       it "finds a bunch of objects and puts them immediately" do
    #         stash.find([@frank.id, igor.id]).should == [@frank, igor]
    #         stash.size.should == 2
    #         stash[@frank.id].should == @frank
    #         stash[igor.id].should == igor
    #       end
    # 
    #       it "doesn't ask ActiveRecord to find objects if they're already in the stash" do
    #         stash.put(@frank)
    #         User.should_receive(:find).with([igor.id]).and_return([igor])
    #         stash.find([@frank.id, igor.id]).should == [@frank, igor]
    #       end
    # 
    #       it "returns them in the presented order" do
    #         stash.find([@frank.id, igor.id]).should == [@frank, igor]
    #         stash.find([igor.id, @frank.id]).should == [igor, @frank]
    #       end
    # 
    #       it "works ok even if there are duplicate ids" do
    #         stash.find([@frank.id, igor.id, @frank.id, @frank.id, igor.id]).should == [@frank, igor, @frank, @frank, igor]
    #       end
    # 
    #       it "only sends unique ids to ActiveRecord if there are duplicate ids" do
    #         User.should_receive(:find).with([@frank.id, igor.id]).and_return([@frank, igor])
    #         stash.find([@frank.id, igor.id, @frank.id, @frank.id, igor.id]).should == [@frank, igor, @frank, @frank, igor]
    #       end
    # 
        end
    # 
    #   end
    # 
    #   describe "class" do
    #     class Thing
    #       def id
    #         object_id
    #       end
    #     end
    # 
    #     it "returns the stash for a class via []" do
    #       r1 = Stash[Thing]
    #       r1.should be_a(Stash)
    #       Stash[Thing].should == r1
    #     end
    # 
    #     it "stores itself in a Thread Local" do
    #       @r1 = nil
    #       @r2 = nil
    #       Thread.new {@r1 = Stash[Thing]}
    #       Thread.new {@r2 = Stash[Thing]}
    #       @r1.should_not be_nil
    #       @r2.should_not be_nil
    #       @r2.should_not == @r1
    #     end
    # 
    #     it "can clear all" do
    #       Stash[Thing].put([Thing.new, Thing.new])
    #       Stash[Thing].size.should == 2
    #       Stash.clear_all
    #       Stash[Thing].size.should == 0
    #     end
    #   end

  end
end