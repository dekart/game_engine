/*global $, if_fb_initialized, FB, Spinner */

var StreamDialog = {
  show: function(post_options, callback){
    var options = $.extend(true, {}, post_options, {
      method: 'stream.publish'
    });

    if_fb_initialized(function(){
      FB.ui(options, function(response){
        callback.call(this, response);
      });

      $(document).trigger('facebook.dialog');
    });
  }
};

$(function(){
  $(document).on('click', 'a[data-stream-dialog]', function(e){
    e.preventDefault();

    var story_data = $.extend($(this).data(), { 'app': I18n.t('app_name') });
    var story_type = story_data.streamDialog;

    var story_options = {
      attachment: {
        name:        I18n.t("stories." + story_type + ".title", story_data),
        description: I18n.t("stories." + story_type + ".description", story_data),
        href: app_location,
        media: [{
          type: "image",
          src:  story_data.image,
          href: app_location
        }]
      },
      action_links: [{
        text: I18n.t("stories." + story_type + ".action_link", story_data) ||
          I18n.t('stories.default.action_link', story_data),
        href: app_location
      }]
    };

    StreamDialog.show(story_options, function(response){
      if(response) {
        _gaq.push(['_trackEvent', 'Stream Dialog', story_type + " - Published", null, null]);
      }

      $("#dialog .close").click();
    });

    return false;
  });
});