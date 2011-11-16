class Admin::EventsController < Admin::BaseController
  def new
    @container = params[:container].camelcase.constantize

    @event = Event::Base.by_name(params[:type]).new(
      @container.event_options
    )

    render :layout => :ajax_layout
  end
end
