DeleteAccount = Backbone.View.extend({
	el: $(document),
	initialize: function () {
		console.log("INIT")
	},
	events: {
	  'click .DeleteAccount': 'update'
	},
	update: function () {
	  console.log("update !");
	  alert(1);
	}
  });