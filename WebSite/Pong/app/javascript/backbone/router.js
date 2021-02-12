window.app.ApplicationRouter = Backbone.Router.extend({
  routes: {
    // "": "home",
    "guild": "guild",
    "play": "play",
    "account": "account",
  },
  home: function() {
    $.get("/").then(function(data){
      $("#content").html("<div id='content-home'>" + ($(data).find("#content-home").html()) + "</div>");
    });
  },
  account: function() {
    $.get("/account").then(function(data){
      $("#content").html("<div id='content-account'>" + ($(data).find("#content-account").html()) + "</div>");
    });
  },
  play: function() {
    $.get("/play").then(function(data){
      $("#content").html("<div id='content-play'>" + ($(data).find("#content-play").html()) + "</div>");
    });
  },
  guild: function() {
    $.get("/guild").then(function(data){
      $("#content").html("<div id='content-guild'>" + ($(data).find("#content-guild").html()) + "</div>");
    });
  },
});