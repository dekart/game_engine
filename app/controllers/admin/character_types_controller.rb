class Admin::CharacterTypesController < Admin::BaseController
  def index
    @character_types = CharacterType.without_state(:deleted)
  end

  def new
    @character_type = CharacterType.new

    if params[:character_type]
      @character_type.attributes = params[:character_type]

      @character_type.valid?
    end
  end

  def create
    @character_type = CharacterType.new(params[:character_type])

    if @character_type.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_character_types_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @character_type = CharacterType.find(params[:id])

    if params[:character_type]
      @character_type.attributes = params[:character_type]

      @character_type.valid?
    end
  end

  def update
    @character_type = CharacterType.find(params[:id])

    if @character_type.update_attributes(params[:character_type])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_character_types_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(CharacterType.find(params[:id]))
  end
end
