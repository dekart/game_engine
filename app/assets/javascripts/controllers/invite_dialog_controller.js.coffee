this.InviteDialogController = class extends DialogController
  sendLimit: 25
  storageLifespan: 3600000 # 1 hour

  @show: (type, options, callback)->
    @controller ?= new @()

    if_fb_initialized ()=>
      @controller.show(type, options, callback)

  setupEventListeners: ->
    super

    @el.on('click', '.user:not(.sent)', @.onUserClick)
    @el.on('click', '.send button:not(.disabled)', @.onSendButtonClick)
    @el.on('click', '.stats .select_all', @.onSelectAllClick)
    @el.on('click', '.stats .deselect_all', @.onDeselectAllClick)

  show: (@type, options, @callback)->
    @options = $.extend(true,
      {
        dialog:
          method: 'apprequests'
          data:
            type: @type
        request:
          type: @type
      },
      options
    )

    @exclude_ids = {}
    @friends = null

    @visible_users = []
    @scroll = 0

    @loading = true

    @.fetchRecipients()
    @.loadExcludeIds()

    super

  fetchRecipients: ->
    stored_data = JSON.parse(sessionStorage.getItem('fb_friends'))

    if stored_data and stored_data.characterId == Character.first().id and stored_data.savedAt > Date.now() - @.storageLifespan
      @friends = stored_data.data

      @.launchWhenPopulated()
    else
      FB.getLoginStatus((response)=>
        if response.authResponse
          FB.api('/fql',
            q: 'SELECT uid, name, is_app_user FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY name',
            (r)=>
              @friends = r.data

              sessionStorage.setItem('fb_friends',
                JSON.stringify(
                  characterId: Character.first().id
                  savedAt: Date.now()
                  data: @friends
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
    return false unless @friends and @exclude_ids[@type]

    @users = $.map(@friends, (user)=>
      if _.contains(@exclude_ids[@type], user.uid) or @options.dialog.to? and not _.contains(@options.dialog.to, user.uid)
        null
      else
        user.selected = true
        user
    )

    @visible_users = @users

    @loading = false

    @.render()


  render: ->
    if @loading
      @.updateContent(I18n.t('common.loading'))
    else
      @.updateContent(
        @.renderTemplate('invite_dialog/dialog', @)
      )

      @tabs = @el.find('.friend_selector').tabs()

      @el.find('.friend_selector').on('select.tab', @.onTabSelect)
      @el.find('.tab_content').on('scroll', @.onUserListScroll)

      @.renderUserList()
      @.updateBars()


  renderUserList: ->
    unless @cell_size
      @.calculateUserCellSize()

    @tabs.current_container.find('.users').css(
      height: Math.ceil(@visible_users.length / @users_per_row) * @cell_size.height
    )

    users_to_skip = @scroll * @users_per_row

    code = []

    for user in @visible_users.slice(users_to_skip, users_to_skip + @users_per_page)
      i = @visible_users.indexOf(user)

      code.push(
        JST['views/invite_dialog/user'](
          user: user
          position:
            x: (i % @users_per_row) * @cell_size.width
            y: Math.floor(i / @users_per_row) * @cell_size.height
        )
      )

    @tabs.current_container.find('.users').html(code.join(''))

  calculateUserCellSize: ->
    @tabs.current_container.find('.users').append(JST['views/invite_dialog/user'](user: @friends[0], position: {x: 0, y: 0}))

    cell = @tabs.current_container.find('.user').eq(0)

    @cell_size = {
      width: cell.outerWidth(true)
      height: cell.outerHeight(true)
    }

    @users_per_row = Math.floor(@tabs.current_container.width() / @cell_size.width)
    @users_per_page = Math.ceil(@tabs.current_container.height() / @cell_size.height + 1) * @users_per_row


  filterUsers: ->
    @visible_users = []

    for user in @.usersByCurrentFilter()
      @visible_users.push(user) unless user.sent

    @tabs.current_container.scrollTop(0)
    @scroll = 0

    @.renderUserList()
    @.updateBars()

  usersByFilter: (filter)->
    result = []

    for user in @users
      switch filter
        when 'all'
          result.push(user)
        when 'app_users'
          result.push(user) if user.is_app_user
        else
          result.push(user) unless user.is_app_user

    result

  usersByCurrentFilter: ->
    @.usersByFilter(@tabs.current_tab.data('filter'))

  toggleUser: (uid)->
    user = _.find(@users, (u)=> u.uid == uid)

    user.selected = not user.selected

    @.renderUserList()
    @.updateBars()

  updateBars: ()->
    @.updateStatsBar()
    @.updateSendBar()

  updateStatsBar: ()->
    selected = _.select(@visible_users, (u)-> u.selected).length

    stats = @el.find('.stats')

    stats.find('.total').html(@visible_users.length)
    stats.find('.value').html(selected)

    stats.find('.deselect_all').toggle(selected != 0)
    stats.find('.select_all').toggle(selected < @visible_users.length)

  updateSendBar: ()->
    all_users = @.usersByCurrentFilter()
    selected = _.select(all_users, (u)-> u.selected)
    sent = _.select(all_users, (u)-> u.sent)

    @el.find('.send button').toggleClass('disabled', selected.length == 0)

    @el.find('.progress_bar .percentage').animate(
      width: if all_users.length == 0 then 0 else Math.floor(100 * sent.length / all_users.length) + '%',
      500
    )

  sendRequests: (to)->
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

  onUserListScroll: ()=>
    new_scroll = Math.floor(@tabs.current_container.scrollTop() / @cell_size.height)

    if @scroll != new_scroll
      @scroll = new_scroll

      @.renderUserList()

  onTabSelect: =>
    @.filterUsers()

  onUserClick: (e)=>
    @.toggleUser($(e.currentTarget).data('uid'))

  onSendButtonClick: ()=>
    users_to_send = _.select(@.usersByCurrentFilter(), (u)-> u.selected).slice(0, @.sendLimit)

    ids = _.pluck(users_to_send, 'uid')

    @.sendRequests(ids)

    for user in users_to_send
      user.selected = false
      user.sent = true

    @.renderUserList()

    @el.find('.user.sent').fadeOut(1500).promise().done(=>
      @.filterUsers()
    )

  onSelectAllClick: ()=>
    for user in @.usersByCurrentFilter()
      user.selected = true unless user.sent

    @.renderUserList()
    @.updateBars()

  onDeselectAllClick: ()=>
    for user in @.usersByCurrentFilter()
      user.selected = false unless user.sent

    @.renderUserList()
    @.updateBars()
