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
		'click #practice_game': 'Game_new_practice'
    },
	Game_new_ranked: function (e) {

		console.log("new ranked game");
		$.post(
			'/histories/find_or_create',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#tournaments_end").val(),
				"ranked": "true", "war_match": "no"
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

		console.log("new practice game");
		$.post(
			'/histories/find_or_create',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#tournaments_end").val(),
				"ranked": "false", "war_match": "no"
			},
			function (data) 
			{
				if (data.status == "error")
					notification("Error", data.info);
				else
					window.location.href = "/#show_game/" + data.id.toString() ;
			},
		);
	}
});