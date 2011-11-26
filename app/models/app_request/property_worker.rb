class AppRequest::PropertyWorker < AppRequest::Base
  protected
  
  def previous_similar_requests
    super.with_target(target)
  end
  
  def later_similar_requests
    super.with_target(target)
  end
  
  def after_accept
    super
    
    target.add_worker!(receiver)
  end
end