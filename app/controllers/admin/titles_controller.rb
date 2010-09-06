class Admin::TitlesController < Admin::BaseController
  def index
    @titles = Title.all
  end

  def new
    @title = Title.new
  end

  def create
    @title = Title.new(params[:title])

    if @title.save
      unless_continue_editing do
        redirect_to admin_titles_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @title = Title.find(params[:id])
  end

  def update
    @title = Title.find(params[:id])

    if @title.update_attributes(params[:title])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_titles_path
      end
    else
      render :action => :edit
    end
  end

  def destroy
    @title = Title.find(params[:id])

    @title.destroy

    redirect_to admin_titles_path
  end
end
