here = File.expand_path(File.dirname(__FILE__))
require  "#{here}/spec_helper"
require  "#{here}/active_record_spec_helper"

module Treasury
  describe Storage do
    
    describe '#for_class' do      
      it "returns a TreasureStorage for Treasure objects" do
        (Storage.for_class(Treasure).is_a? TreasureStorage).should be_true
        (Storage.for_class(User).is_a? TreasureStorage).should be_true
      end

      class FairyDust
        extend Treasury
      end

      it "returns a StashStorage for Treasury objects" do
        (Storage.for_class(FairyDust).is_a? StashStorage).should be_true
      end

      it "returns an ActiveRecordStorage for AR models" do
        (Storage.for_class(ActiveUser).is_a? ActiveRecordStorage).should be_true
      end
    end
    
    class TestStorage < Storage
      def size
        raise Unimplemented
      end

      def clear
        raise Unimplemented
      end

      def store_old(objects)
        raise Unimplemented
      end

      def store_new(objects)
        raise Unimplemented
      end

      def find_by_criterion(criterion)
        raise Unimplemented
      end

      def find_by_keys(keys)
        raise Unimplemented
      end
      
    end
  end
end
