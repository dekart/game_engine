class Admin::ContestGroupsController < Admin::BaseController
  def new
    @contest_group = parents.contest.groups.build
  end

  def create
    @contest_group = parents.contest.groups.build(params[:contest_group])

    if @contest_group.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_contests_path
      end
    else
      render :new
    end
  end

  def edit
    @contest_group = ContestGroup.find(params[:id])
  end

  def update
    @contest_group = ContestGroup.find(params[:id])

    if @contest_group.update_attributes(params[:contest_group].reverse_merge!(:payouts => nil))
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_contests_path
      end
    else
      render :edit
    end
  end
  
  def destroy
    @contest_group = ContestGroup.find(params[:id])

    @contest_group.destroy

    redirect_to admin_contests_path
  end
end
