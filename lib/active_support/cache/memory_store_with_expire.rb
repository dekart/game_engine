module ActiveSupport
  module Cache
    class MemoryStoreWithExpire < MemoryStore
      def initialize
        super
        @expire_time = {}
      end
      
      def read(name, options = nil)
        super
        
        if @expire_time[name].nil?
          @data[name]
        elsif @expire_time[name] > Time.now
          @data[name]
        else
          delete(name)
          
          nil
        end
      end

      def write(name, value, options = nil)
        super.tap do
          if options && options[:expires_in]
            @expire_time[name] = options[:expires_in].from_now
          end
        end
      end
      
      def delete(name, options = nil)
        super.tap do 
          @expire_time.delete(name)
        end
      end
      
      def exist?(name, options = nil)
        super && @expire_time[name] > Time.now
      end
      
      def clear
        super
        @expire_time.clear
      end
    end
  end
end
      