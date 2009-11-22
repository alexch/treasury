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
end
