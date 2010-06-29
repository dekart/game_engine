module UsersHelper
  def user_permission_dialog(*permissions)
    if current_user.should_request_permissions? and (permissions - current_user.permissions).any?
      dom_ready(<<-CODE)
        $(document).bind('facebook.ready', function(){
          FB.Connect.showPermissionDialog('#{ permissions.join(",") }', function(response){
            $.post('#{add_permissions_user_path(:current)}', response);
          });
        });
      CODE
    end
  end
end