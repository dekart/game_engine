class Admin::BaseController < ApplicationController
  skip_before_filter :check_character_existance
  skip_before_filter :tracking_requests

  before_filter :admin_required

  layout "admin/layouts/application"

  protected

  def admin_required
    redirect_from_iframe root_url(:canvas => true) unless current_user.admin? || ENV['OFFLINE']
  end

  def ajax_layout
    "admin/layouts/ajax"
  end

  def unless_continue_editing(options = {}, &block)
    if params[:continue]
      render options.reverse_merge(:action => :edit)
    else
      yield
    end
  end

  def t(*args)
    key = args.shift

    super(
      *(
        [key.starts_with?(".") ? "admin.#{controller_name}.#{action_name}#{key}" : key] + args
      )
    )
  end
  
  def publish_hide_delete_states(object)
    state_change_action(object) do |state|
      case state
      when :visible
        object.publish if object.can_publish?
      when :hidden
        object.hide if object.can_hide?
      when :deleted
        object.mark_deleted if object.can_mark_deleted?
      end
    end
  end
  
  def change_position_action(object)
    @direction = params[:direction].to_sym
    @object = object
    
    case @direction
    when :up
      object.move_higher
      
      @sibling = @object.lower_item
    when :down
      object.move_lower
      
      @sibling = @object.higher_item
    end
    
    render :template => 'admin/common/change_position', :layout => false
  end
  
  def state_change_action(object, options = {})
    @object = object
    @options = options

    yield(params[:state].to_sym)

    render :template => 'admin/common/change_state', :layout => false
  end
  
  def destroy_action(object)
    @object = object
    
    render :template => 'admin/common/destroy', :layout => false
  end
end
