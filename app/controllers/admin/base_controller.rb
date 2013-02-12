class Admin::BaseController < ApplicationController
  skip_authentication_filters
  skip_before_filter :tracking_requests
  skip_before_filter :check_standalone

  before_filter :http_authentication, :unless => :current_facebook_user

  layout "admin/layouts/application"

  protected

  def admin_required
    redirect_to(root_url) unless current_user.admin? || ENV['OFFLINE']
  end

  def http_authentication
    unless @current_user = authenticate_with_http_basic { |login, password| admin_authenticate(login, password) }
      request_http_basic_authentication
    end
  end

  def admin_authenticate(login, password)
    user = User.find(login)
    user if user.admin? && admin_login_key(user) == password
  end

  def admin_login_key(user)
    Digest::MD5.hexdigest(user.id.to_s + Rails::Config.session.secret)[0, 8]
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
