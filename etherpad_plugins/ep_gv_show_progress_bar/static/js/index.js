// copied over from ep_post_message/static/index.js and modified

var editor = require("ep_etherpad-lite/static/js/pad_editor").padeditor
  , _ = require("ep_etherpad-lite/static/js/underscore")._;

exports.aceInitialized = function (hook, context) {
  var pluginSettings = window.ep_gv_plugins || {
    domains: []
  };

  window.addEventListener("message", function (e) {
    var object = JSON.parse(e.data)
      , origin = e.origin
      , source = e.source;


    if (_.include(pluginSettings.domains, origin)) {
      if (object.method === 'show_progress_bar') {
        var event = document.createEvent('Event');
        event.initEvent('show_progress_bar', true, true);
        document.dispatchEvent(event);
      }
      else if (object.method === 'hide_progress_bar') {
        var event = document.createEvent('Event');
        event.initEvent('hide_progress_bar', true, true);
        document.dispatchEvent(event);
      }
    }
  }, false);
};
