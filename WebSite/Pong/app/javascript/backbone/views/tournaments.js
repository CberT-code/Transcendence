function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
	console.log("notif");
}
ViewTournaments = Backbone.View.extend({
    el: $(document),
    initialize: function () {
	},
    events: {
		'click #create_tournament': 'Create_tournament',
		'click .playerJoin': 'PlayerJoin',
    },
	Create_tournament: function () {
		if ($("#tournamentName").val() == "")
			notification("error", "Please complete the tournament name...");
		else if ($("#tournamentdescription").val() == "")
			notification("error", "Please complete the description...");
		else {
			$.post(
				'/tournaments',
				{
					'authenticity_token': $('meta[name=csrf-token]').attr('content'),
					"tournamentname": $("#tournament_name").val(),
					"tournamentdescription": $("#tournament_description").val(),
					"start": $("#tournament_start").val(),
					"end": $("#tournament_end").val(),
					"maxpoints": $("#maxpoints").val(),
					"speed": $("#speed").val(),
				},
				function (data) {
					if (data == 'error-1')
						notification("error", "Please complete the tournament name...");
					else if (data == 'error-2')
						notification("error", "Please complete the description...");
					else if (data == 'error-3')
						notification("error", "Wrong, start day...");
					else if (data == 'error-4')
						notification("error", "Wrong, end day...");
					else if (data == 'error-5')
						notification("error", "Wrong number of max points.");
					else if (data == 'error-6')
						notification("error", "Wrong speed for the game.");
					else{
						// $('#header-tournament').attr('onClick',"window.location='/#show_tournament/" + data + "'");
						window.location.href = "#tournaments" ;
					}
				},
				'text'
			);
		}
	},
	PlayerJoin: function (e) {
		console.log(e.currentTarget);
		$.post(
			'/tournaments/playerJoin/',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id_tournament": $(e.currentTarget).val(),
			},
			function (data) {
				Backbone.history.loadUrl();
			},
			'text'
		);
	}
});