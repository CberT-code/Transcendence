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
				},
				function (data) {
					if (data == 'error-1')
						notification("error", "Please complete the tournament name...");
					else if (data == 'error-2')
						notification("error", "Please complete the description...");
					else if (data == 'error-3')
						notification("error", "Wrong, max number of member...");
					else if (data == 'error-4')
						notification("error", "This name is already used...");
					else if (data == 'error-5')
						notification("error", "Oversize description...");
					else{
						// $('#header-tournament').attr('onClick',"window.location='/#show_tournament/" + data + "'");
						window.location.href = "#tournaments" ;
					}
				},
			'text'
			);
		}
	},
});