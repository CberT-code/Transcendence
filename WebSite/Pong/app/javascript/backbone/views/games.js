function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

ViewGuilds = Backbone.View.extend(
{
    el: $(document),
    initialize: function () {
    },
    events: {
		'click #new_game': 'Game_new',
    },
	Game_new: function (e) {

		console.log($("#tournament_id").val())
		$.post(
			'/histories/find_or_create',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"tournament_id": $("#tournament_id").val(),
			},
			function (data) 
			{
				if (data == "error_tournament")
					notification("error", "This tournament id doesn't exist.");
				else
					window.location.href = "#show_game/" + data ;
			},
		);
	},
});