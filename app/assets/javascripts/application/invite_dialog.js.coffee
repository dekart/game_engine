this.InviteDialog = class
  send_limit: 25

  storageLifespan: 3600000 # 1 hour

  constructor: (@type, options, @callback)->
    @page = 0
    @filter = 'all'
    @exclude_ids = {}
    @fb_friends = null

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
          exclude_ids: $.merge(options.dialog.exclude_ids || [], @exclude_ids[@type] || [])
      }
    )

    if_fb_initialized ()=>
      @.selectRecipientsAndSendRequest()

  sendRequest: (to)->
    dialog_options = @options.dialog

    if to
      dialog_options.to = to.join(',')

    FB.ui(dialog_options, (response)=>
      if response
        $.post(
          '/app_requests.json', $.extend({request_id: response.request, to: response.to}, @options.request)
        ).success((response)=>
          GA.appRequestSent(response.type, response.target?.name, response.count)

          @callback?()
        )
    )

  selectRecipientsAndSendRequest: (to)->
    return if @.launchWhenPopulated()

    Spinner.show(200, I18n.t('app_requests.invite_dialog.spinner_text'))

    @.fetchRecipients()
    @.loadExcludeIds()

  fetchRecipients: ->
    stored_data = JSON.parse(sessionStorage.getItem('fb_friends'))


    if stored_data and stored_data.characterId == Character.first().id and stored_data.savedAt > Date.now() - @.storageLifespan
      @fb_friends = stored_data.data

      @.launchWhenPopulated()
    else
      console.log('load')
      FB.getLoginStatus((response)=>
        if response.authResponse
          FB.api('/fql',
            q: 'SELECT uid, name, is_app_user FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY name',
            (r)=>
              @fb_friends = r.data

              sessionStorage.setItem('fb_friends',
                JSON.stringify(
                  characterId: Character.first().id
                  savedAt: Date.now()
                  data: @fb_friends
                )
              )

              @.launchWhenPopulated()
          )
      )

  loadExcludeIds: ->
    $.getJSON('/app_requests/invite', type: @type, (data)=>
      @exclude_ids[@type] = data.exclude_ids

      @.launchWhenPopulated()
    )


  launchWhenPopulated: ()->
    return false unless @fb_friends and @exclude_ids[@type]

    @users = $.map(@fb_friends, (user)=>
      if _.contains(@exclude_ids[@type], user.uid) or @options.dialog.to? and not _.contains(@options.dialog.to, user.uid)
        null
      else
        user
    )

    Spinner.hide()

    if @users.length > 0
      @.renderDialog()
      @.setupEventListeners()

    true # Should return true if all data was successfully populated and dialog rendered

  renderDialog: ()->
    DialogController.show(JST['views/invite_dialog'](@))

    @dialog_el = $('#invite_dialog')

    # Caching user element height for image load calculations
    @user_height = @dialog_el.find('.user').eq(0).outerHeight(true)
    @users_per_row = Math.floor(@dialog_el.find('.users').eq(0).width() / @dialog_el.find('.user').eq(0).outerWidth(true))
    @users_per_page = Math.ceil(@dialog_el.find('.users').eq(0).height() / @user_height) * @users_per_row

    @.updateBars()
    @.loadUserImages()


  setupEventListeners: ()->
    @dialog_el.on('click', '.filter', @.onFilterClick)
    @dialog_el.on('click', '.user:not(.sent)', @.onUserClick)
    @dialog_el.on('click', '.stats .select_all', @.onSelectAllClick)
    @dialog_el.on('click', '.stats .deselect_all', @.onDeselectAllClick)
    @dialog_el.on('click', '.send button:not(.disabled)', @.onSendButtonClick)
    @dialog_el.find('.users').on('scroll', @.onUserListScroll)

    Visibility.every(500, ()=>
      if @scroll_updated
        @scroll_updated = false

        @.loadUserImages()
    )

  loadUserImages: ()=>
    el = @dialog_el.find('.users')

    user_el = el.find('.user:not(.hidden, .sent)')
    scroll = el.scrollTop()

    first_user = Math.floor(scroll / @user_height) *  @users_per_row
    last_user = first_user + @.users_per_page + @users_per_row

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
    users_to_send = @dialog_el.find('.user.selected:not(.hidden, .sent)').slice(0, @.send_limit)

    ids = users_to_send.map(()->
      parseInt($(@).data('uid'), 10);
    ).get()

    @.sendRequest(ids)

    users_to_send.removeClass('selected').addClass('sent').fadeOut(1500, ()=>
      @.loadUserImages()
      @.updateBars()
    )

  onUserListScroll: ()=>
    new_scroll = @dialog_el.find('.users').scrollTop()

    if @current_scroll != new_scroll
      @current_scroll = new_scroll

      @scroll_updated = true

  changeFilter: (filter)->
    @filter = filter

    @dialog_el.find('.filter')
      .removeClass('selected')
      .filter("[data-filter='#{ filter }']")
      .addClass('selected')

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
    @.loadUserImages()

  updateStatsBar: ()->
    all_users = @dialog_el.find('.user:not(.hidden)')
    selected_users = all_users.filter('.selected')
    selectable_users = all_users.filter(':not(.sent)')

    stats = @dialog_el.find('.stats')

    stats.find('.total').html(all_users.length)
    stats.find('.value').html(selected_users.length)

    stats.find('.deselect_all').toggle(selected_users.length != 0)
    stats.find('.select_all').toggle(selectable_users.length > 0 && selected_users.length != selectable_users.length)

  updateSendBar: ()->
    all_users = @dialog_el.find('.user:not(.hidden)')
    selected_users  = all_users.filter('.selected')
    sent_users      = all_users.filter('.sent')

    @dialog_el.find('.send button')
      .toggleClass('disabled', selected_users.length == 0)

    @dialog_el.find('.progress_bar .percentage')
      .animate(
        width: if all_users.length == 0 then 0 else Math.floor(100 * sent_users.length / all_users.length) + '%',
        500
      )

  updateBars: ()->
    @.updateStatsBar()
    @.updateSendBar()
