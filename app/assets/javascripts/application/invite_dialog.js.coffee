this.InviteDialog = class
  send_limit: 25
  users_per_page: 18
  users_per_row: 3
  user_element_height: 56

  fb_friends: null
  exclude_ids: {}

  constructor: (@type, options, @callback)->
    @page = 0
    @filter = 'all'
    @options = $.extend(true,
      {
        dialog:
          method: 'apprequests'
          data:
            type: @type
        request:
          type: @type
      },
      options,
      {
        dialog:
          exclude_ids: $.merge(options.dialog.exclude_ids || [], @.exclude_ids[@type] || [])
      }
    )

    if_fb_initialized ()=>
      if options.dialog.to
        @.sendRequest()
      else
        @.selectRecipientsAndSendRequest()

  sendRequest: (to)->
    dialog_options = @options.dialog

    if to
      dialog_options.to = to.join(',')

    FB.ui(dialog_options, (response)=>
      if response
        $.post(
          '/app_requests', $.extend({request_id: response.request, to: response.to}, @options.request)
        ).success(@callback)
    )

  selectRecipientsAndSendRequest: ()->
    unless @.launchWhenPopulated()
      FB.getLoginStatus((response)=>
        if response.authResponse
          FB.api('/fql',
            q: 'SELECT uid, name, is_app_user FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY name',
            (r)=>
              @.fb_friends = r.data

              @.launchWhenPopulated()
          )
      )

      $.getJSON('/app_requests/invite', type: @type, (data)=>
        @.exclude_ids[@type] = data.exclude_ids

        @.launchWhenPopulated()
      )

  launchWhenPopulated: ()->
    return false unless @.fb_friends and @.exclude_ids[@type]

    @users = $.map(@.fb_friends, (user)=>
      if $.inArray(user.uid, @.exclude_ids[@type]) > -1 then null else user
    )

    @.renderDialog()
    @.setupEventListeners()

    true # Should return true if all data was successfully populated and dialog rendered

  renderDialog: ()->
    $.dialog(
      JST['invite_dialog/dialog'](@)
    )

    @dialog_el = $('#invite_dialog')

    @.updateBars()
    @.loadUserImages()


  setupEventListeners: ()->
    @dialog_el.on('click', '.filter', @.onFilterClick)
    @dialog_el.on('click', '.user:not(.sent)', @.onUserClick)
    @dialog_el.on('click', '.stats .select_all', @.onSelectAllClick)
    @dialog_el.on('click', '.stats .deselect_all', @.onDeselectAllClick)
    @dialog_el.on('click', '.send .button', @.onSendButtonClick)
    @dialog_el.find('.users').on('scroll', @.loadUserImages)

  loadUserImages: ()=>
    el = @dialog_el.find('.users')

    user_el = el.find('.user')
    scroll = el.scrollTop()

    first_user = Math.floor(scroll / @.user_element_height) *  @.users_per_row
    last_user = first_user + @.users_per_page + @.users_per_row

    user_el.slice(first_user, last_user).find('img:not([src])').each (i,e)->
      i = $(e)
      i.attr(src: i.data('src'))

  onUserClick: (e)=>
    $(e.currentTarget).toggleClass('selected')

    @.updateBars()

  onSelectAllClick: ()=>
    @dialog_el.find('.user:not(.hidden, .sent)').addClass('selected')

    @.updateBars()

  onDeselectAllClick: ()=>
    @dialog_el.find('.user:not(.hidden, .sent)').removeClass('selected')

    @.updateBars()

  onUserClick: (e)=>
    $(e.currentTarget).toggleClass('selected')

    @.updateBars()

  onFilterClick: (e)=>
    filter_el = $(e.currentTarget)
    new_filter = filter_el.data('filter')

    if new_filter != @filter
      @.changeFilter(new_filter)

  onSendButtonClick: ()=>
    users_to_send = @dialog_el.find('.user:not(.hidden, .sent)').slice(0, @.send_limit)

    ids = users_to_send.map(()->
      parseInt($(@).data('uid'), 10);
    ).get()

    @.sendRequest(ids)

    users_to_send.removeClass('selected').addClass('sent')

    @.updateBars()

  changeFilter: (filter)->
    @filter = filter

    @dialog_el.find('.filter')
      .removeClass('ui-tabs-selected ui-state-active')
      .filter("[data-filter='#{ filter }']")
      .addClass('ui-tabs-selected ui-state-active')

    @dialog_el.find('.users')
      .scrollTop(0)
      .find('.user').each(()->
        u = $(@)

        switch filter
          when 'all'
            u.removeClass('hidden')
          when 'app_users'
            u.toggleClass('hidden', !u.hasClass('app_user')) # hide all non-app-users
          else
            u.toggleClass('hidden', u.hasClass('app_user')) # hide all that don't have the class
      )

    @.updateBars()

  updateStatsBar: ()->
    all_users = @dialog_el.find('.user:not(.hidden)')
    selected_users = all_users.filter('.selected')

    stats = @dialog_el.find('.stats')

    stats.find('.total').html(all_users.length)
    stats.find('.value').html(selected_users.length)

    stats.find('.deselect_all').toggle(selected_users.length != 0)
    stats.find('.select_all').toggle(selected_users.length != all_users.length)

  updateSendBar: ()->
    all_users = @dialog_el.find('.user:not(.hidden)')
    selected_users  = all_users.filter('.selected')
    sent_users      = all_users.filter('.sent')

    @dialog_el.find('.send .button')
      .toggleClass('disabled', selected_users.length == 0)

    @dialog_el.find('.progress_bar .percentage')
      .animate(
        width: if all_users.length == 0 then 0 else Math.floor(100 * sent_users.length / all_users.length) + '%',
        500
      )


  updateBars: ()->
    @.updateStatsBar()
    @.updateSendBar()
###

                .inviteDialog(users, data.templates.user, function(ids){
                  callback(ids);
                  invite_dialog.excludeIds(invite_type, ids);
                });
###