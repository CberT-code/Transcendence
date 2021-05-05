function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

ViewGames = Backbone.View.extend(
{
    el: $(document),
    initialize: function () {
    },
	close: function() {
		clearInterval(waiting);
	},
    events: {
		'click #ranked_game': 'Game_new_ranked',
		'click #practice_game': 'Game_new_practice',
		'click #continue': 'Continue_game'
		// 'click #left_PP_show_game': 'Show_user_from_pp',
		// 'click #right_PP_show_game': 'Show_user_from_pp'
    },
	Game_new_ranked: function (e) {
		$.post(
			'/histories/start_game',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"tournament_id": $("#tournaments_end").val(),
				"ranked": true,
			},
			function (data) 
			{
				if (data.status == "error")
					notification("Error", data.info);
				else
					window.location.href = "/#show_game/" + data.id.toString() ;
			},
		);
	},
	Game_new_practice: function (e) {
		$.post(
			'/histories/start_game',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"tournament_id": $("#tournaments_end").val(),
			},
			function (data) 
			{
				if (data.status == "error")
					notification("Error", data.info);
				else
					window.location.href = "/#show_game/" + data.id.toString() ;
			},
		);
	},
	Continue_game: function (e) {
		window.location.href = "/#show_game/" + $(e.currentTarget).val();
	}
	// Show_user_from_pp: function(e) {
	// 	console.log("show_user : " + $(e.currentTarget).val());
	// 	if ($(e.currentTarget).val() != -1)
	// 		window.location.href = "/#show_user/" + $(e.currentTarget).val();
	// }
});