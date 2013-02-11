window.FacebookHelper =
  fbProfilePic: (uid, type)->
    @safe """
      <img
        src="https://graph.facebook.com/#{ uid }/picture?type=#{ type }&return_ssl_resources=1"
      />
    """

  fbProfilePicSlot: (uid, type)->
    @safe """
      <img
        data-src="https://graph.facebook.com/#{ uid }/picture?type=#{ type }&return_ssl_resources=1"
        src="/assets/1px.gif"
      />
    """
