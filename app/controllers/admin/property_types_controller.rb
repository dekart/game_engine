class Admin::PropertyTypesController < Admin::BaseController
  def index
    @types = PropertyType.without_state(:deleted).paginate(:order => :level, :page => params[:page])
  end

  def new
    @type = PropertyType.new

    if params[:property_type]
      @type.attributes = params[:property_type]

      @type.valid?
    end
  end

  def create
    @type = PropertyType.new(params[:property_type])

    if @type.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_property_types_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @type = PropertyType.find(params[:id])

    if params[:property_type]
      @type.attributes = params[:property_type]

      @type.valid?
    end
  end

  def update
    @type = PropertyType.find(params[:id])

    if @type.update_attributes(params[:property_type])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_property_types_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(PropertyType.find(params[:id]))
  end
end
