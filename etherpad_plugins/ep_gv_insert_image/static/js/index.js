// copied over from ep_post_message/static/index.js and modified

var editor = require("ep_etherpad-lite/static/js/pad_editor").padeditor
  , _ = require("ep_etherpad-lite/static/js/underscore")._
  , availableMethods
  , postback = function (source, origin, object) {
      var message = JSON.stringify({
        callbackKey: object.callbackKey,
        data: availableMethods[object.method](object.args)
      });
      source.postMessage(message, origin);
    };

availableMethods = {
  addImage: function(url) {
    editor.ace.callWithAce(function (ace) {
      editor.ace.callWithAce(function(ace){
        var rep = ace.ace_getRep();
        ace.ace_doInsertImage(rep, url);
      }, 'img', true);
    });    
  }
};

exports.aceInitialized = function (hook, context) {
  var pluginSettings = window.ep_gv_insert_image || {
    domains: []
  };

  window.addEventListener("message", function (e) {
    var object = JSON.parse(e.data)
      , origin = e.origin
      , source = e.source;

    if (_.include(pluginSettings.domains, origin)) {
      postback(source, origin, object);
    }
  }, false);

  var editorInfo = context.editorInfo;
  editorInfo.ace_doInsertImage = _(doInsertImage).bind(context);
};

function doInsertImage(rep, src) {
    var rep = this.rep, documentAttributeManager = this.documentAttributeManager;
    var lineNumber = rep.selStart[0];
    var src = "<img src=" + src + ">";
    documentAttributeManager.setAttributeOnLine(lineNumber, 'img', src);
}
