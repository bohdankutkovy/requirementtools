// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require gritter
//= require projects
//= require active_scaffold
//= require bootstrap-treeview
//= require treebuild.js
//= require bootstrap-filestyle
//= require dashboard
//= require bootstrap-sprockets



$(document).ajaxError(function(event, request) {
    var msg = request.getResponseHeader('X-Message');
    if (msg) alert(msg);
});


