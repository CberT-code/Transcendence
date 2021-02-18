window.app.ApplicationRouter = Backbone.Router.extend({
  routes: {
    "": "home",
    "account": "account",
    "tchat": "tchat",
    "play": "play",
    "guilds": "guilds",
    "tournaments": "tournaments",
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
    new ViewAccount();
  },
  tchat: function() {
    $.get("/tchat").then(function(data){
      $("#content").html("<div id='content-tchat'>" + ($(data).find("#content-tchat").html()) + "</div>");
    });
  },
  play: function() {
    $.get("/play").then(function(data){
      $("#content").html("<div id='content-play'>" + ($(data).find("#content-play").html()) + "</div>");
    });
  },
  guilds: function() {
    $.get("/guilds").then(function(data){
	  $("#content").html("<div id='content-guilds'>" + ($(data).find("#content-guilds").html()) + "</div>");
    });
  },
  tournaments: function() {
    $.get("/tournaments").then(function(data){
      $("#content").html("<div id='content-tournaments'>" + ($(data).find("#content-tournaments").html()) + "</div>");
    });
  },
});