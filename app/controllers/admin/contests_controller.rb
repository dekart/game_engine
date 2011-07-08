class Admin::ContestsController < Admin::BaseController
  def index
    @contests = Contest.without_state(:deleted)
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

  def publish
    @contest = Contest.find(params[:id])

    @contest.publish if @contest.can_publish?

    redirect_to admin_contests_path
  end

  def finish
    @contest = Contest.find(params[:id])

    @contest.finish if @contest.can_finish?

    redirect_to admin_contests_path
  end

  def destroy
    @contest = Contest.find(params[:id])

    @contest.mark_deleted if @contest.can_mark_deleted?

    redirect_to admin_contests_path
  end
end
