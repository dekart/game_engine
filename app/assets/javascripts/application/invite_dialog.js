/*global $, if_fb_initialized, FB, Spinner */

var InviteDialog = (function(){
  var users_per_page = 24;
  
  var invite_dialog = {};

  var fnMethods = {
    initialize: function(users, send_button_callback){
      var dialog = $(this);

      // Storing initial data
      dialog.data({ 'users' : users });

      // Styling filters using jQuery UI tab classes
      dialog.find('.friend_selector').addClass('ui-tabs ui-widget ui-widget-content ui-corner-all');
      dialog.find('.friend_selector .filters').addClass('ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all');
      dialog.find('.friend_selector .user_list').addClass('ui-tabs-panel ui-widget-content ui-corner-bottom');
      dialog.find('.filters .filter').addClass('ui-state-default ui-corner-top')
        .first().addClass('ui-tabs-selected ui-state-active');
      
      // Setup page controls
      dialog.find('.previous, .next').click(function(){
        var link = $(this);
      
        if( !link.hasClass('disabled') ){
          fnMethods.goToPage.call(dialog, link.data('page'));
        }
      });
      
      // Setup filter controls
      dialog.find('.filters .filter').click(function(){
        var link = $(this);

        if( !link.hasClass('ui-tabs-selected')){
          fnMethods.applyFilter.call(dialog, link.data('filter'));
        }
      });
      
      // Setup send button
      dialog.find('.send.button').click(function(){
        var button = $(this);
        
        if( button.hasClass('disabled') ){
          return;
        }
        
        var ids = fnMethods.getSelectedIds.call(dialog);
        
        send_button_callback(ids);
        
        fnMethods.markAsSent.call(dialog, ids);
      });
      
      // Binding interface element updates to user list change event
      dialog.bind('user_list_updated.invite_dialog', fnMethods.updateProgressBar);
      dialog.bind('user_selection_changed.invite_dialog', fnMethods.checkButtonAvailability);
      dialog.bind('user_selection_changed.invite_dialog', fnMethods.updateStatsBar);
      
      dialog.delegate('.user', 'click', function(e){
        if(e.target.nodeName == 'INPUT') {
          return;
        }
        
        var checkbox = $(this).find(':checkbox');
        
        checkbox.attr('checked', !checkbox.attr('checked')).trigger('change');
      });
      
      // Track checkbox state change
      dialog.find(':checkbox').live('change', function(){
        var checkbox = $(this);
        
        checkbox.parent('.user').toggleClass('selected', checkbox.attr('checked'));
        
        dialog.trigger('user_selection_changed.invite_dialog');
      });
      
      // Setup search box
      dialog.find('.search input').labelify().keyup(function(){
        var input = $(this);
        var value = input.val();

        if(value != input.data('previous_value')){
          input.data('previous_value', value);
          
          fnMethods.applyFilter.call(dialog, $(this).val());
        }
      });
      
      // Setup stats bar controls
      dialog.find('.select_all').click(function(){
        fnMethods.selectAll.call(dialog);
      });
      
      dialog.find('.deselect_all').click(function(){
        fnMethods.deselectAll.call(dialog);
      });
      
      // Display all users by default
      fnMethods.applyFilter.call(this, 'all');
    },
    
    applyFilter: function(filter){
      var dialog = $(this);
      
      fnMethods.hidePage.call(this, dialog.data('page'));
      dialog.removeData('page');
      
      dialog.find('.user').removeClass('filtered');

      dialog.data('filter', filter);
      dialog.data('max-page', Math.floor(fnMethods.usersByCurrentFilter.call(this).length / users_per_page));
      
      dialog.find('.filter')
        .removeClass('ui-tabs-selected ui-state-active')
        .filter('[data-filter="' + filter +'"]')
        .addClass('ui-tabs-selected ui-state-active');
      
      dialog.trigger('user_list_updated.invite_dialog');
      dialog.trigger('user_selection_changed.invite_dialog');
      
      fnMethods.goToPage.call(this, 0);
    },
    
    usersByCurrentFilter: function(){
      var dialog = $(this);
      var filter = dialog.data('filter') || 'all';
      
      var users = dialog.find('.user.filtered');
      
      if( users.length === 0) {
        if( filter == 'app_users' ){
          users = dialog.find('.user.app_user');
        } else if (filter == 'all') {
          users = dialog.find('.user');
        } else {
          var filter_exp = new RegExp(filter, 'igm');
        
          var ids = $.map(dialog.data('users'), function(user){
            return user.name.search(filter_exp) > -1 ? user.uid : null;
          });
        
          users = dialog.find('.user').filter(function(){
            return $.inArray(parseInt($(this).data('uid'), 10), ids) > -1 ? true : false;
          });
        }
        
        users.addClass('filtered');
      }
      
      return users;
    },
  
    goToPage: function(page){
      var dialog = $(this);
      var max_page = dialog.data('max-page');
    
      if(page < 0 || page > max_page){
        return;
      }
    
      var previous = dialog.find('.previous');
      var next = dialog.find('.next');
      
      previous.data('page', page - 1);
      next.data('page', page + 1);
      
      previous.toggleClass('disabled', page === 0);
      
      next.toggleClass('disabled', page === max_page);
    
      fnMethods.hidePage.call(this, dialog.data('page'));

      dialog.data('page', page);

      fnMethods.showPage.call(this, page);
    },
  
    goToFirstSelected: function(){
      fnMethods.goToPage.call(this, 
        Math.floor(
          fnMethods.getSelectedUsers.call(this).first().index() / users_per_page
        )
      );
    },
  
    usersFromPage: function(page){
      return fnMethods.usersByCurrentFilter.call(this).slice(page * users_per_page, (page + 1) * users_per_page);
    },
  
    showPage: function(page){
      var users = fnMethods.usersFromPage.call(this, page);
    
      if( users.length > 0 ){
        users.find('img[data-image]').each(function(){
          var img = $(this);
      
          img.attr({ src: img.data('image') }).removeAttr( 'data-image' );
        });
      
        users.removeClass('hidden');
      }
    },
  
    hidePage: function(page){
      if(typeof page == 'undefined'){
        return;
      }
      
      var users = fnMethods.usersFromPage.call(this, page || 0);
      
      if( users.length > 0 ){
        users.addClass('hidden');
      }
    },
  
    getSelectedIds: function(){
      return fnMethods.getSelectedUsers.call(this).slice(0, users_per_page).map(function(){
        return parseInt($(this).data('uid'), 10);
      }).get();
    },
    
    getSelectedUsers: function(){
      return fnMethods.usersByCurrentFilter.call(this).filter('.selected');
    },
    
    countSelected: function(){
      return fnMethods.getSelectedUsers.call(this).length;
    },
  
    markAsSent: function(ids){
      var dialog = $(this);
    
      dialog.find('.user').each(function(){
        var user = $(this);
      
        if($.inArray(parseInt(user.data('uid'), 10), ids) > -1){
          user.removeClass('selected').addClass('sent').find('input').remove();
        }
      });
      
      dialog.trigger('user_list_updated.invite_dialog');
      dialog.trigger('user_selection_changed.invite_dialog');
      
      fnMethods.goToFirstSelected.call(this);
    },
    
    updateProgressBar: function(){
      var all_users = fnMethods.usersByCurrentFilter.call(this);
      var sent_users = all_users.filter('.sent');
      
      var dialog = $(this);
      
      dialog.find('.progress_bar .percentage').animate({width : Math.floor(100 * sent_users.length / all_users.length) + '%'}, 500);
    },
    
    updateStatsBar: function(){
      var stats = $(this).find('.stats');
      
      var all_users = fnMethods.usersByCurrentFilter.call(this).length;
      var selected_users = fnMethods.countSelected.call(this);
      
      stats.find('.value').html(selected_users);
      stats.find('.total').html(all_users);
      
      stats.find('.deselect_all').toggle(selected_users !== 0);
      stats.find('.select_all').toggle(selected_users !== all_users);
    },

    checkButtonAvailability: function(){
      var button = $(this).find('.send.button');

      button.toggleClass('disabled', fnMethods.countSelected.call(this) === 0);
    },
    
    selectAll: function(){
      fnMethods.usersByCurrentFilter.call(this).addClass('selected').find(':checkbox').attr('checked', true);

      $(this).trigger('user_selection_changed.invite_dialog');
    },
    
    deselectAll: function(){
      fnMethods.getSelectedUsers.call(this).removeClass('selected').find(':checkbox').attr('checked', false);

      $(this).trigger('user_selection_changed.invite_dialog');
    }
    
  };

  $.fn.inviteDialog = function(method) {
    var result;
    
    // Method calling logic
    if ( fnMethods[method] ){
      result = fnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else {
      result = fnMethods.initialize.apply(this, arguments);
    }
    
    return result;
  };



  $.extend(invite_dialog, {
    excluded_ids: {},
  
    excludeIds : function(type, ids){
      invite_dialog.excluded_ids[type] = $.merge(invite_dialog.getExcludedIds(type), ids);
    },
  
    getExcludedIds: function(type){
      return invite_dialog.excluded_ids[type] || [];
    },
  
    show: function(invite_type, invite_options, callback){
      var options = $.extend(true, 
        {
          dialog : {
            method: 'apprequests',
            data: {
              type : invite_type
            }
          },
          request : {
            type : invite_type
          }
        }, 
        invite_options,
        {
          dialog : {
            exclude_ids: $.merge(invite_options.dialog.exclude_ids || [], invite_dialog.getExcludedIds(invite_type))
          }
        }
      );

      if_fb_initialized(function(){
        if(options.dialog.to){
          invite_dialog.sendRequest(options, callback);
        } else {
          invite_dialog.selectRecipients(invite_type, options, function(ids){
            var options_with_receivers = $.extend(true, 
              {
                dialog : {
                  to : ids.join(',')
                }
              }, 
              options
            );

            invite_dialog.sendRequest(options_with_receivers, callback);
          });
        }

        $(document).trigger('facebook.dialog');
      });
    },
  
    sendRequest: function(options, callback){
      FB.ui(options.dialog, function(response){
        if(response){
          $('#ajax').load('/app_requests', $.extend({request_id: response.request, to: response.to}, options.request), function(){ 
            callback(); 
          });
        }
      });
    },

    selectRecipients: function(invite_type, options, callback){
      Spinner.show();

      FB.getLoginStatus(function(response) {
        if (response.authResponse) {
          FB.api('/fql', 
            {
              q : 'SELECT uid, name, is_app_user FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY name'
            }, 
            function(response){
              Spinner.hide();

              var exclude_ids;
              var users;

              $.getJSON('/app_requests/invite', {type: invite_type}, function(data){

                exclude_ids = data.exclude_ids[invite_type];
                users = $.map(response.data, function(user){
                  return $.inArray(user.uid, exclude_ids) > -1 ? null : user;
                });

                $.dialog(
                  $(data.dialog_template).tmpl({
                    options : options,
                    users : users
                  })
                );

                $('#invite_dialog').inviteDialog(users, function(ids){
                  callback(ids);
                  invite_dialog.excludeIds(invite_type, ids);
                });
              });
            }
          );
        }
      });
    }
  });
  
  return invite_dialog;
})();
