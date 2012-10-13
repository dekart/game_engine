module GS
  class EventLogger
    include GS::Backends::Redis
    include GS::Flushing::Immediate

    def initialize
      @lock = Mutex.new
    end

    def log(*args)
      attributes = args.extract_options!
      type, label = args

      event = {
        :time   => Time.now.to_i,
        :type   => type,
        :label  => label
      }

      attributes.each do |key, value|
        event[key.to_sym] = value if value != 0
      end

      store_event(event)
    end
  end
end