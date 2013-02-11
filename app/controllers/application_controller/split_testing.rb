class ApplicationController
  module SplitTesting
    def self.included(base)
      base.class_eval do
        #before_filter :setup_split_tests, :if => :current_user
      end
    end

    def setup_split_tests
      @split_test = split_test(
        :id => 1,
        :create_if => current_user.created_at > 1.minute.ago,
        :name => "Mission Tutorial Arrow",
        :variations => [:without, :with]
      )
    end

    def split_test(options)
      if index = $redis.hget("split_test_#{ options[:id] }", current_user.id)
        index = index.to_i
      elsif options[:create_if]
        index = current_user.id % options[:variations].size

        $redis.hset("split_test_#{ options[:id] }", current_user.id, index)
      end

      options.merge(:variation => options[:variations][index]) if index
    end
  end
end