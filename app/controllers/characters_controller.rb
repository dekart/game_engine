class CharactersController < ApplicationController
  skip_before_filter :require_facebook_permissions, :only => :new
  prepend_before_filter :require_facebook_permissions_if_standalone, :only => :new

  skip_before_filter :check_character_existance,            :only => [:new, :create]
  skip_before_filter :check_user_ban,                       :only => [:new, :create]

  prepend_before_filter :check_character_existance_or_create, :only => :index

  around_filter :check_user_app_requests, :only => :index

  helper_method :character_types

  def index
    @news = current_character.news.latest(Setting.i(:dashboard_news_count))
    @newcomer = params[:newcomer]
  end

  def upgrade
    if request.post?
      @success = current_character.upgrade_attributes!(params)

      render :json => current_character.as_json_for_upgrade.merge(
        :success => @success
      )
    else
      render :json => current_character.as_json_for_upgrade
    end
  end

  def show
    @character = Character.find(params[:id])

    @secured = (@character.key == params[:id])

    @wall_enabled = Setting.b(:wall_enabled) && !current_character.restrict_talking?

    if @wall_enabled
      @wall_posts = @character.wall_posts.paginate(:page => params[:page])
    end
  end

  def new
    if current_character && params[:_force_form].blank?
      redirect_to root_url
    else
      @character = Character.new
      @character.name ||= Setting.s(:character_default_name)
      @character.character_type ||= character_types.first

      render :layout => 'unauthorized'
    end
  end

  def create
    if current_character
      redirect_to root_url
    else
      @character = current_user.build_character

      if params[:character]
        @character.name = params[:character][:name]
        @character.character_type = GameData::CharacterType[params[:character][:character_type_id]]
      end

      @character.character_type ||= character_types.first

      if @character.save
        # Always redirect newcomers to missions
        redirect_to root_url(:newcomer => true)
      else
        render :action => :new, :layout => 'unauthorized'
      end
    end
  end

  def edit
    @character = current_character

    if flash[:premium_change_name]
      @allow_name = true
    else
      redirect_to root_url
    end
  end

  def hospital
  end

  def hospital_heal
    @result = current_character.hospital!
  end

  protected

  def character_types
    @character_types ||=
      if params[:default_type_id] and default_type = GameData::CharacterType[params[:default_type_id]]
        [default_type] + (GameData::CharacterType.all - [default_type])
      else
        GameData::CharacterType.all
      end
  end

  def check_character_existance_or_create
    if current_character
      true
    elsif current_user
      create
    else
      check_character_existance
    end
  end

  def require_facebook_permissions_if_standalone
    return unless Setting.b(:app_standalone_enabled)

    require_facebook_permissions unless ENV['OFFLINE'] || fb_canvas?
  end
end
