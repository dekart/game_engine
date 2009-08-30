module GoalLogger
  class << self
    def logger
      @@logger ||= Logger.new(File.join(Rails.root, "log", "goals.log"), "daily")
    end

    def log(*args)
      logger << "#{Time.now.to_i}|#{args.join("|")}\n"
    end
  end
end