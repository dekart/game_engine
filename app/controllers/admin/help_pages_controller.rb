class Admin::HelpPagesController < Admin::BaseController
  def index
    @pages = HelpPage.all(:order => :alias)
  end

  def new
    @page = HelpPage.new(params[:help_page])
  end

  def create
    @page = HelpPage.new(params[:help_page])

    if @page.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_help_pages_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @page = HelpPage.find(params[:id])
  end

  def update
    @page = HelpPage.find(params[:id])

    if @page.update_attributes(params[:help_page])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_help_pages_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(HelpPage.find(params[:id]))
  end
end
