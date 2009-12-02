require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Treasury
  describe "Treasury" do
    class Thing
      def id
        object_id
      end
    end

    it "returns the repository for a class via []" do
      r1 = Treasury[Thing]
      r1.should be_a(Repository)
      Treasury[Thing].should == r1
    end

    it "stores itself in a Thread Local" do
      @r1 = nil
      @r2 = nil
      Thread.new {@r1 = Treasury[Thing]}
      Thread.new {@r2 = Treasury[Thing]}
      @r1.should_not be_nil
      @r2.should_not be_nil
      @r2.should_not == @r1
    end

    it "can clear all" do
      Treasury[Thing].put([Thing.new, Thing.new])
      Treasury[Thing].size.should == 2
      Treasury.clear_all
      Treasury[Thing].size.should == 0
    end
  end
  
  describe "a mixed-in treasury object class" do
    
    class Animal
      extend Treasury
      def id
        object_id
      end
    end
    
    describe 'class methods' do
      before do
        Treasury.clear_all
      end
      
      it 'should have a #treasury_size and #put' do
        Animal.treasury_size.should == 0
        Animal.put(Animal.new, Animal.new)
        Animal.treasury_size.should == 2
      end
      
      it 'should #<<' do
        Animal << Animal.new 
        Animal.treasury_size.should == 1
        Animal. << Animal.new, Animal.new
        Animal.treasury_size.should == 3
      end
      
      it 'should have a #search method' do
        find_me = Animal.new
        Animal.put(find_me, Animal.new)
        Animal.search(find_me.id).should == [find_me]
      end
      
      it 'should #clear_treasury' do
        Animal.put(Animal.new, Animal.new)
        Animal.treasury_size.should == 2 # just to check
        Animal.clear_treasury
        Animal.treasury_size.should == 0
      end
    end
    
    describe 'instance methods' do
      it 'should have a #put method' do
        Treasury.clear_all
        animal = Animal.new
        animal.put
        Animal.treasury_size.should == 1
      end
    end
    
     
  end
end
