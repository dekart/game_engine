module Rails
  def self.restart!
    Rails.logger.debug "Restarting server..."
    
    FileUtils.touch Rails.root.join("tmp", "restart.txt")
  end
end