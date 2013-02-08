window.FacebookHelper =
  fbProfilePic: (uid, type)->
    @safe "<img src='#{ @.fbProfilePicPath(uid, type) }' />"

  fbProfilePicPath: (uid, type)->
    "https://graph.facebook.com/#{ uid }/picture?type=#{ type }&return_ssl_resources=1"