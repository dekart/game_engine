class Admin::TitlesController < Admin::BaseController
  def index
    @titles = Title.without_state(:deleted).all(:order => "name ASC")
  end

  def new
    @title = Title.new
  end

  def create
    @title = Title.new(params[:title])

    if @title.save
      flash[:success] = t(".success")

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

  def change_state
    publish_hide_delete_states(Title.find(params[:id]))
  end
end
