here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"
require  "#{here}/active_record_spec_helper"

module Treasury
  describe Store do
    
    describe '#for_class' do      
      it "returns a TreasureStore for Treasure objects" do
        (Store.for_class(Treasure).is_a? TreasureStore).should be_true
        (Store.for_class(User).is_a? TreasureStore).should be_true
      end

      class FairyDust
        extend Treasury
      end

      it "returns a StashStore for Treasury objects" do
        (Store.for_class(FairyDust).is_a? StashStore).should be_true
      end

      it "returns an ActiveRecordStore for AR models" do
        (Store.for_class(ActiveUser).is_a? ActiveRecordStore).should be_true
      end
    end
    
    class TestStore < Store
      def size
        raise Unimplemented
      end

      def clear
        raise Unimplemented
      end

      def put_old(objects)
        raise Unimplemented
      end

      def put_new(objects)
        raise Unimplemented
      end

      def find_by_criterion(criterion)
        raise Unimplemented
      end

      def find_by_ids(ids)
        raise Unimplemented
      end
      
    end
  end
end
