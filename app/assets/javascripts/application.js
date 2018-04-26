// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree ./vendor
//= require_tree .

// BS Tooltip: Instantiate with trigger option for
    // mouseenter and mouseleave
    // so tooltip content remains open while hovering on it

 function tooltipPersist() {
  $(".info-checkbox").tooltip()
    .on("mouseenter", function () {
      var _this = this;
      $(this).tooltip("show");
      $(".tooltip").on("mouseleave", function () {
          $(_this).tooltip('hide');
      });
    }).on("mouseleave", function () {
      var _this = this;
      setTimeout(function () {
        if (!$(".tooltip:hover").length) {
            $(_this).tooltip("hide");
        }
      }, 400);
  });
}

jQuery(function($) {
  $('a[data-toggle=tooltip]').tooltip();

  tooltipPersist();
});

window.newsframes || (window.newsframes = {});
