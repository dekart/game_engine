class GoogleAnalytics
  trackEvent: (category, action, label, value)->
    _gaq?.push(['_trackEvent', category, action, label, value])

  appRequestAccepted: (type, label, value)->
    @.trackEvent('Requests', "#{type} - Accepted", label, value || 1)

window.GA = new GoogleAnalytics()
