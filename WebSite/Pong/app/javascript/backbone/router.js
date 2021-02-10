window.app.ApplicationRouter = Backbone.Router.extend({
  routes: {
    "test": "test",
    "lol": "lol",
    "": "test",
  },
  test: function(id) {
	console.log("TEST");
	// $("#divname").html(content);
  },

  lol: function(pattern) {
    console.log("LOL");
  }
});