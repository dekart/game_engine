class Admin::StoriesController < Admin::BaseController
  def index
    @stories = Story.all(:order => "alias")
  end

  def new
    @story = Story.new
  end

  def create
    @story = Story.new(params[:story])

    if @story.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_stories_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @story = Story.find(params[:id])
  end

  def update
    @story = Story.find(params[:id])

    if @story.update_attributes(params[:story])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_stories_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(Story.find(params[:id]))
  end
end
