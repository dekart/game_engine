var InviteDialog = (function(){
  var users_per_page = 24;
  
  var invite_dialog = {};

  var fnMethods = {
    initialize: function(users, send_button_callback){
      var dialog = $(this);
    
      dialog.data({ 'per-page' : users_per_page, 'users' : users });

      dialog.find('.previous, .next').click(function(){
        var link = $(this);
      
        if( !link.hasClass('disabled') ){
          fnMethods.goToPage.call(dialog, link.data('page'));
        }
      });
      
      // Styling filters using jQuery UI tab classes
      dialog.find('.friend_selector').addClass('ui-tabs ui-widget ui-widget-content ui-corner-all');
      dialog.find('.friend_selector .filters').addClass('ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all');
      dialog.find('.friend_selector .user_list').addClass('ui-tabs-panel ui-widget-content ui-corner-bottom');
      dialog.find('.filters .filter').addClass('ui-state-default ui-corner-top')
        .first().addClass('ui-tabs-selected ui-state-active');
      
      // User filtering event
      dialog.find('.filters .filter').click(function(){
        var link = $(this);

        if( !link.hasClass('ui-tabs-selected')){
          fnMethods.applyFilter.call(dialog, link.data('filter'));
        }
      });
      
      // User invite delivery event
      dialog.find('.send.button').click(function(){
        var button = $(this);
        
        if( button.hasClass('disabled') ){
          return;
        }
        
        var ids = fnMethods.getSelectedIds.call(dialog);
        
        send_button_callback(ids);
        
        fnMethods.markAsSent.call(dialog, ids);
      });
      
      dialog.bind('user_list_updated.invite_dialog', fnMethods.checkButtonAvailability);
      dialog.bind('user_list_updated.invite_dialog', fnMethods.updateProgressBar);
      dialog.bind('user_list_updated.invite_dialog', fnMethods.updateStatsBar);
      
      dialog.find(':checkbox').live('change', function(){
        var checkbox = $(this);
        
        checkbox.parent('.user').toggleClass('selected', checkbox.attr('checked'))
        
        fnMethods.updateStatsBar.call(dialog);
      })
      
      dialog.find('.search input').labelify().keyup(function(){
        var input = $(this);
        var value = input.val();

        if(value != input.data('previous_value')){
          input.data('previous_value', value);
          
          fnMethods.applyFilter.call(dialog, $(this).val());
        }
      });
      
      dialog.find('.select_all').click(function(){
        fnMethods.selectAll.call(dialog);
        fnMethods.updateStatsBar.call(dialog);
      })
      
      dialog.find('.deselect_all').click(function(){
        fnMethods.deselectAll.call(dialog);
        fnMethods.updateStatsBar.call(dialog);
      })
      
      fnMethods.applyFilter.call(this, 'all');
    },
    
    applyFilter: function(filter){
      var dialog = $(this);
      
      fnMethods.hidePage.call(this, dialog.data('page'));
      dialog.removeData('page');
      
      dialog.find('.user').removeClass('filtered');

      dialog.data('filter', filter);
      dialog.data('max-page', Math.floor(fnMethods.usersByCurrentFilter.call(this).length / dialog.data('per-page')));
      
      dialog.find('.filter').removeClass('ui-tabs-selected ui-state-active').filter('[data-filter="' + filter +'"]').addClass('ui-tabs-selected ui-state-active');
      
      dialog.trigger('user_list_updated.invite_dialog');
      
      fnMethods.goToPage.call(this, 0);
    },
    
    usersByCurrentFilter: function(){
      var dialog = $(this);
      var filter = dialog.data('filter') || 'all';
      
      var users = dialog.find('.user.filtered');
      
      if( users.length == 0) {
        if( filter == 'app_users' ){
          var users = dialog.find('.user.app_user');
        } else if (filter == 'all') {
          var users = dialog.find('.user');
        } else {
          var filter_exp = new RegExp(filter, 'igm');
        
          var ids = $.map(dialog.data('users'), function(user){
            return user.first_name.search(filter_exp) > -1 ? user.uid : null;
          })
        
          var users = dialog.find('.user').filter(function(){
            return $.inArray(parseInt($(this).data('uid')), ids) > -1 ? true : false;
          })
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
      
      previous.toggleClass('disabled', page == 0);
      
      next.toggleClass('disabled', page == max_page);
    
      fnMethods.hidePage.call(this, dialog.data('page'));

      dialog.data('page', page);

      fnMethods.showPage.call(this, page);
    },
  
    goToFirstSelected: function(){
      var dialog = $(this);
    
      fnMethods.goToPage.call(this, Math.floor(dialog.find('.user.selected').first().index('.user') / users_per_page));
    },
  
    usersFromPage: function(page){
      var dialog = $(this);
      var per_page = dialog.data('per-page');
    
      var users = fnMethods.usersByCurrentFilter.call(this).slice(page * per_page, (page + 1) * per_page);

      return users;
    },
  
    showPage: function(page){
      var dialog = $(this);
    
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
      
      var dialog = $(this);
      
      var users = fnMethods.usersFromPage.call(this, page || 0);
      
      if( users.length > 0 ){
        users.addClass('hidden');
      }
    },
  
    getSelectedIds: function(){
      var ids = fnMethods.getSelectedUsers.call(this).slice(0, users_per_page).map(function(){
        return parseInt($(this).data('uid'));
      }).get();
      
      return ids;
    },
    
    getSelectedUsers: function(){
      var users = fnMethods.usersByCurrentFilter.call(this).filter('.selected');
      
      return users;
    },
    
    countSelected: function(){
      var count = fnMethods.getSelectedUsers.call(this).length;
      
      return count;
    },
  
    markAsSent: function(ids){
      var dialog = $(this);
    
      dialog.find('.user').each(function(){
        var user = $(this);
      
        if($.inArray(parseInt(user.data('uid')), ids) > -1){
          user.removeClass('selected').addClass('sent').find('input').remove();
        }
      });
      
      dialog.trigger('user_list_updated.invite_dialog');
      
      fnMethods.goToFirstSelected.call(this);
    },
    
    updateProgressBar: function(){
      var dialog = $(this);
      
      var all_users = fnMethods.usersByCurrentFilter.call(this);
      var sent_users = all_users.filter('.sent');
      
      dialog.find('.progress_bar .percentage').animate({width : Math.floor(100 * sent_users.length / all_users.length) + '%'}, 500);
    },
    
    updateStatsBar: function(){
      var stats = $(this).find('.stats');
      
      var all_users = fnMethods.usersByCurrentFilter.call(this).length;
      var selected_users = fnMethods.countSelected.call(this);
      
      stats.find('.value').html(selected_users);
      stats.find('.total').html(all_users);
      
      stats.find('.deselect_all').toggle(selected_users != 0);
      stats.find('.select_all').toggle(selected_users != all_users);
    },

    checkButtonAvailability: function(){
      var button = $(this).find('.send.button');

      button.toggleClass('disabled', fnMethods.countSelected.call(this) == 0);
    },
    
    selectAll: function(){
      var dialog = $(this);
      
      fnMethods.usersByCurrentFilter.call(this).addClass('selected').find(':checkbox').attr('checked', true);
    },
    
    deselectAll: function(){
      var dialog = $(this);
      
      fnMethods.getSelectedUsers.call(this).removeClass('selected').find(':checkbox').attr('checked', false);
    }
    
  }

  $.fn.inviteDialog = function(method) {
    // Method calling logic
    if ( fnMethods[method] ){
      var result = fnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else {
      var result = fnMethods[ 'initialize' ].apply(this, arguments);
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
          invite_dialog.sendRequest(options, callback)
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
      var dialog_template = $('#invite_dialog_template');

      Spinner.show();

      FB.getLoginStatus(function(response) {
        if (response.authResponse) {
          FB.api('/fql', 
            {
              q : 'SELECT uid, first_name, is_app_user FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY first_name'
            }, 
            function(response){
              Spinner.hide();
            
              var exclude_ids = invite_dialog.getExcludedIds(invite_type);
              var users = $.map(response.data, function(user){
                return $.inArray(user.uid, exclude_ids) > -1 ? null : user;
              });
              
              $.dialog(
                dialog_template.tmpl({
                  options : options,
                  users : users
                })
              );

              $('#invite_dialog').inviteDialog(users, function(ids){
                callback(ids);
                
                invite_dialog.excludeIds(invite_type, ids);
              });
            }
          );
        }
      });
    }
  });
  
  return invite_dialog;
})();
