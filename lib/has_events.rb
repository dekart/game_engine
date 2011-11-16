module HasEvents
  def has_events(*args)
    preload_events!

    options = args.extract_options!

    options.reverse_merge!(
      :bind_to => args.first
    )
    
    args.flatten!

    cattr_accessor :event_triggers
    self.event_triggers  = args

    cattr_accessor :event_options
    self.event_options = options

    if respond_to?(:serialize) and column_names.include?("events")
      serialize :events, Event::Collection

      send(:include, ActiveRecordMethods)
    else
      send(:include, NonActiveRecordMethods)
    end
  end

  def event_triggers_for_select
    event_triggers.collect{|trigger| [trigger.to_s.humanize, trigger]}
  end

  def preload_events!
    Dir[File.join(RAILS_ROOT, "app", "models", "event", "*.rb")].each do |file|
      load(file)
    end
  end

  module ActiveRecordMethods
    def events
      super || Event::Collection.new
    end

    def events=(collection)
      super(Event::Collection.parse(collection))
    end
  end

  module NonActiveRecordMethods
    def events
      @events || Event::Collection.new
    end

    def events=(collection)
      @events = Event::Collection.parse(collection)
    end

    def events?
      !events.empty?
    end
  end
end
