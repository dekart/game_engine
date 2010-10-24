class Admin::BoostsController < Admin::BaseController
  def index
    @boosts = Boost.all(:order => :name)
  end

  def new
    @boost = Boost.new
  end

  def create
    @boost = Boost.new(params[:boost])

    if @boost.save
      flash[:success] = t(".success")
      unless_continue_editing do
        redirect_to admin_boosts_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @boost = Boost.find(params[:id])
  end

  def update
    @boost = Boost.find(params[:id])

    if @boost.update_attributes(params[:boost])
      flash[:success] = t(".success")
      unless_continue_editing do
        redirect_to admin_boosts_path
      end
    else
      render :action => :edit
    end
  end

  def publish
    @boost = Boost.find(params[:id])
    @boost.publish if @boost.can_publish?

    redirect_to admin_boosts_path
  end

  def hide
    @boost = Boost.find(params[:id])
    @boost.hide if @boost.can_hide?

    redirect_to admin_boosts_path
  end

  def destroy
    @boost = Boost.find(params[:id])
    @boost.mark_deleted if @boost.can_mark_deleted?

    redirect_to admin_boosts_path
  end
end
