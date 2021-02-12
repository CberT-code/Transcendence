window.app.ApplicationRouter = Backbone.Router.extend({
  routes: {
    "test": "test",
    "lol": "lol",
    "": "test",
    "account": "account",
  },
  account: function() {
    console.log("account")
    $.get("/account").then(function(data){
      alert(data);
      alert($(data).html()); // Now it Works too
      //$("#content").html($(data).find("content").text());
    });
  },
  test: function() {
	  console.log("TEST");
  },

  lol: function() {
    console.log("LOL");
  }
});