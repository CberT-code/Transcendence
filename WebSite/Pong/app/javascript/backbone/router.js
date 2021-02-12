window.app.ApplicationRouter = Backbone.Router.extend({
  routes: {
    "test": "test",
    "lol": "lol",
    "": "test",
    "account": "account",
  },
  account: function() {
    $.get("/account").then(function(data){
		$("#content").html("<div id='content-account'>" + ($(data).find("#content-account").html()) + "</div>");
    });
  },
  test: function() {
	  console.log("TEST");
  },

  lol: function() {
    console.log("LOL");
  }
});