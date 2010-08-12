class Admin::NewslettersController < Admin::BaseController
  def index
    @newsletters = Newsletter.paginate(:page => params[:page], :order => "created_at DESC")
  end

  def new
    @newsletter = Newsletter.new
  end

  def create
    @newsletter = Newsletter.new(params[:newsletter])

    if @newsletter.save
      flash[:success] = t(".success")
      
      unless_continue_editing do
        redirect_to admin_newsletters_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @newsletter = Newsletter.find(params[:id])
  end

  def update
    @newsletter = Newsletter.find(params[:id])

    if @newsletter.update_attributes(params[:newsletter])
      flash[:success] = t(".success")
      
      unless_continue_editing do
        redirect_to admin_newsletters_path
      end
    else
      render :action => :edit
    end
  end

  def destroy
    @newsletter = Newsletter.find(params[:id])

    @newsletter.destroy

    redirect_to admin_newsletters_path
  end

  def deliver
    @newsletter = Newsletter.find(params[:id])

    @newsletter.start_delivery!

    redirect_to admin_newsletters_path
  end

  def pause
    @newsletter = Newsletter.find(params[:id])

    @newsletter.pause_delivery!

    redirect_to admin_newsletters_path
  end
end
