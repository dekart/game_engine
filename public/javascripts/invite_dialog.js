var InviteDialog = (function(){
  var invite_dialog = {};

  var fnMethods = {
    initialize: function(){
      var list = $(this);
    
      list.data({
        'per-page' : 10
      });

      list.find('.previous, .next').click(function(){
        var link = $(this);
      
        if( !link.hasClass('disabled') ){
          fnMethods.goToPage.call(list, link.data('page'));
        }
      });
      
      list.find('.filter').click(function(){
        var link = $(this);
        
        if( !link.hasClass('selected')){
          fnMethods.applyFilter.call(list, link.data('filter'));
        }
      });
    
      fnMethods.goToPage.call(this, 0);
    },
    
    applyFilter: function(filter){
      var list = $(this);
      
      list.data('filter', filter);
      list.data('max-page', Math.floor(fnMethods.usersByCurrentFilter.call(this).length / list.data('per-page')))
      
      list.find('.filter').removeClass('selected').filter('[data-filter=' + filter +']').addClass('selected');
      list.find('.user').hide();
      
      fnMethods.goToPage.call(this, 0);
    },
    
    usersByCurrentFilter: function(){
      var list = $(this);
      
      if( list.data('filter') == 'app_users'){
        return list.find('.user.app_user');
      } else {
        return list.find('.user');
      }
    },
  
    goToPage: function(page){
      var list = $(this);
      var max_page = list.data('max-page');
    
      if(page < 0 || page > max_page){
        return;
      }
    
      var previous = list.find('.previous');
      var next = list.find('.next');
      
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
    
      if(typeof list.data('page') != 'undefined'){
        fnMethods.hidePage.call(this, list.data('page'));
      }
    
      fnMethods.showPage.call(this, page);
    
      list.data('page', page);
    },
  
    goToFirstSelected: function(){
      var list = $(this);
    
      list.find(':checked').first().parent().index('.user')
    },
  
    usersFromPage: function(page){
      var list = $(this);
      var per_page = list.data('per-page');
    
      return fnMethods.usersByCurrentFilter.call(this).slice(page * per_page, (page + 1) * per_page);
    },
  
    showPage: function(page){
      var list = $(this);
    
      var users = fnMethods.usersFromPage.call(this, page);
    
      users.show().find('img[data-image]').each(function(){
        var img = $(this);
      
        img.attr( 'src', img.data('image') ).removeAttr( 'data-image' );
      });
    },
  
    hidePage: function(page){
      fnMethods.usersFromPage.call(this, page).hide();
    },
  
    getSelectedIds: function(size){
      return fnMethods.usersByCurrentFilter.call(this).find(':checked').slice(0, size).map(function(){
        return parseInt(this.getAttribute('value'));
      }).get();
    },
  
    markAsSent: function(ids){
      var list = $(this);
    
      list.find('.user').each(function(){
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

  $.fn.inviteFriendSelector = function(method) {
    // Method calling logic
    if ( !fnMethods[method] ) {
      var method = 'initialize'
    }
  
    return fnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
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
          invite_dialog.selectRecipients(invite_type, function(ids){
            var options_with_receivers = $.extend(true, 
              {
                dialog : {
                  to : ids
                }
              }, 
              options
            );

            //invite_dialog.sendRequest(options_with_receivers, callback);
          })
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

    selectRecipients: function(invite_type, callback){
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
                  friends : $.map(response.data, function(user){
                    return $.inArray(user.uid, exclude_ids) > -1 ? null : user;
                  })
                })
              );

              var friend_list = $('#invite_dialog .friend_list');

              friend_list.inviteFriendSelector();

              $('#invite_dialog .send.button').click(function(){
                var ids = friend_list.inviteFriendSelector('getSelectedIds', 20);

                callback(ids);

                friend_list.inviteFriendSelector('markAsSent', ids);
                
                invite_dialog.excludeIds(invite_type, ids);
              })
            }
          );
        }
      });
    }
  });
  
  return invite_dialog;
})();
