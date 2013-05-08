class Admin::ContestsController < Admin::BaseController
  def index
    @contests = Contest.without_state(:deleted).order("started_at DESC")
  end

  def new
    @contest = Contest.new
  end

  def create
    @contest = Contest.new(params[:contest])

    if @contest.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_contests_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @contest = Contest.find(params[:id])
  end

  def update
    @contest = Contest.find(params[:id])

    if @contest.update_attributes(params[:contest])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_contests_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    @contest = Contest.find(params[:id])

    state_change_action(@contest) do |state|
      case state
      when :visible
        @contest.publish if @contest.can_publish?
      when :hidden
        @contest.hide if @contest.can_hide?
      when :finished
        @contest.finish if @contest.can_finish?
      when :deleted
        @contest.mark_deleted if @contest.can_mark_deleted?
      end
    end
  end
end
