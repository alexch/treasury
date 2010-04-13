here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"

module Treasury
  describe "query DSL" do
    before do
      @repository = Repository.new(User)
    end

    describe "individual criteria" do
      it "equals" do
        @repository.criterion_from do |user|
          user.equals('name', 'alice')
        end.should == Criterion::Equals.new(:subject => "name", :value => "alice")
      end

      it ""
    end

  end
end

