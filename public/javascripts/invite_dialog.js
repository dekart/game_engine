var InviteDialog = (function(){
  var users_per_page = 10;
  
  var invite_dialog = {};

  var fnMethods = {
    initialize: function(send_button_callback){
      var dialog = $(this);
    
      dialog.data({ 'per-page' : users_per_page });

      dialog.find('.previous, .next').click(function(){
        var link = $(this);
      
        if( !link.hasClass('disabled') ){
          fnMethods.goToPage.call(dialog, link.data('page'));
        }
      });
      
      dialog.find('.filter').click(function(){
        var link = $(this);
        
        if( !link.hasClass('selected')){
          fnMethods.applyFilter.call(dialog, link.data('filter'));
        }
      });
    
      dialog.find('.send.button').click(function(){
        var button = $(this);
        
        if( button.hasClass('disabled') ){
          return;
        }
        
        var ids = fnMethods.getSelectedIds.call(dialog);
        
        send_button_callback(ids);
        
        fnMethods.markAsSent.call(dialog, ids);
        
        if( fnMethods.countSelected.call(dialog) == 0 ){
          button.addClass('disabled');
        }
      });

      fnMethods.goToPage.call(this, 0);
    },
    
    applyFilter: function(filter){
      var dialog = $(this);
      
      fnMethods.hidePage.call(this, dialog.data('page'));
      
      dialog.data('filter', filter);
      dialog.data('max-page', Math.floor(fnMethods.usersByCurrentFilter.call(this).length / dialog.data('per-page')));
      
      dialog.find('.filter').removeClass('selected').filter('[data-filter=' + filter +']').addClass('selected');
      
      fnMethods.goToPage.call(this, 0);
    },
    
    usersByCurrentFilter: function(){
      var dialog = $(this);
      
      if( dialog.data('filter') == 'app_users' ){
        return dialog.find('.user.app_user');
      } else {
        return dialog.find('.user');
      }
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
      
      if( page == 0 ){
        previous.addClass('disabled');
      } else {
        previous.removeClass('disabled');
      }
      
      if( page == max_page ){
        next.addClass('disabled');
      } else {
        next.removeClass('disabled');
      }
    
      console.log('goto', page)

      fnMethods.hidePage.call(this, dialog.data('page'));

      dialog.data('page', page);

      fnMethods.showPage.call(this, page);
    },
  
    goToFirstSelected: function(){
      var dialog = $(this);
    
      fnMethods.goToPage.call(this, Math.floor(dialog.find(':checked').first().parent().index('.user') / users_per_page));
    },
  
    usersFromPage: function(page){
      var dialog = $(this);
      var per_page = dialog.data('per-page');
    
      return fnMethods.usersByCurrentFilter.call(this).slice(page * per_page, (page + 1) * per_page);
    },
  
    showPage: function(page){
      var dialog = $(this);
    
      var users = fnMethods.usersFromPage.call(this, page);
    
      if( users.length > 0 ){
        users.find('img[data-image]').each(function(){
          var img = $(this);
      
          img.attr( 'src', img.data('image') ).removeAttr( 'data-image' );
        });
      
        dialog.queue(function(next){
          users.fadeIn(next);
        });
      }
    },
  
    hidePage: function(page){
      var dialog = $(this);
      
      var users = fnMethods.usersFromPage.call(this, page || 0);
      
      if( users.length > 0 ){
        dialog.queue(function(next){
          users.fadeOut(next);
        });
      }
    },
  
    getSelectedIds: function(){
      return fnMethods.usersByCurrentFilter.call(this).find(':checked').slice(0, users_per_page).map(function(){
        return parseInt(this.getAttribute('value'));
      }).get();
    },
    
    countSelected: function(){
      return fnMethods.usersByCurrentFilter.call(this).find(':checked').length;
    },
  
    markAsSent: function(ids){
      var dialog = $(this);
    
      dialog.find('.user').each(function(){
        var user = $(this);
        var checkbox = user.find('input');
      
        if($.inArray(parseInt(checkbox.val()), ids) > -1){
          user.addClass('sent');
          checkbox.remove();
        }
      });
    
      fnMethods.goToFirstSelected.call(this);
    }
  }

  $.fn.inviteDialog = function(method) {
    // Method calling logic
    if ( fnMethods[method] ){
      return fnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else {
      return fnMethods[ 'initialize' ].apply(this, arguments);
    }
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
              q : 'SELECT uid, first_name, pic_square, is_app_user FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY first_name'
            }, 
            function(response){
              Spinner.hide();
            
              var exclude_ids = invite_dialog.getExcludedIds(invite_type);
              
              $.dialog(
                dialog_template.tmpl({
                  options : options,
                  friends : $.map(response.data, function(user){
                    return $.inArray(user.uid, exclude_ids) > -1 ? null : user;
                  })
                })
              );

              $('#invite_dialog').inviteDialog(function(ids){
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
