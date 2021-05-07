function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

ViewWars = Backbone.View.extend(
{
	el: $(document),
    initialize: function () {
	},
    events: {
		'click #Accept': 'Wars_Update',
		'click #Decline': 'Wars_Destroy',
		'click #add': 'Wars_Add',
		'click #remove': 'Wars_Remove',
		'change #histories_points': 'Search',
		'change #histories_nb_players': 'Search',
		'keyup #wars_search': 'Wars_Search',
		'click #attack': 'Wars_Create',
		'click #warMatch_button' : 'warMatch_Start',
		'click #regular_warMatch_button' : 'regular_warMatch_Start'
	},
	Wars_Update: function (e) {
		e.preventDefault();
		$.ajax(
			{
				url: '/wars/' + $(e.currentTarget).val(),
				type: 'PATCH',
				data: 
				{
					"war_id":  $(e.currentTarget).val(),
					'authenticity_token': $('meta[name=csrf-token]').attr('content')
				},
				success: function (data) 
				{
					if (data == "error-accept")
						notification("error", "You cant decline this request...");
					else{
						window.location.href = "#edit_war/" + data ;
					}
				},
			},
		);
		
	},
	Wars_Destroy: function (e) {
		e.preventDefault();
		console.log($(e.currentTarget).val());
		$.ajax(
			{
				url: '/wars/' + $(e.currentTarget).val(),
				type: 'DELETE',
				data: 
				{
					"war_id":  $(e.currentTarget).val(),
					'authenticity_token': $('meta[name=csrf-token]').attr('content')
				},
				success: function (data) 
				{
					if (data == "error-delete")
						notification("error", "You cant decline this request...");
					else{
						Backbone.history.loadUrl();
					}
				},
			},
		);
	},
	Wars_Add: function (e) {
		e.preventDefault();
		console.log($(e.currentTarget).val());
		$.post(
			'/wars/add',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $(e.currentTarget).val(),

			},
			function (data) 
			{
				if (data == '1')
					notification("error", "User already added");
				else if (data == '2')
					notification("error", "Team already full");
				Backbone.history.loadUrl();
			},
			'text'
		);
	},
	Wars_Remove: function (e) {
		e.preventDefault();
		console.log($(e.currentTarget).val());
		$.post(
			'/wars/remove',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $(e.currentTarget).val(),
			},
			function (data) 
			{
				if (data == '1')
				notification("error", "this user not in the team");
				Backbone.history.loadUrl();
			},
			'text'
			);
		},
	Wars_Search: function (e) {
		$("#corp").empty();
		$.post(
			'/wars/search',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				'search' : $("#wars_search").val(),
				'players' : $("#histories_nb_players").val(),
				'points' : $("#histories_points").val(),
			},
			function (data) 
			{
				if (Array.isArray(data)) {
					i = 0;
					data.forEach(
						function(guild) {
							i += 1;
							$("#corp").append("<div class='war'><div id='position'><p>" + i + "</p></div><div id='target'><p>" + guild[0].name + "</p></div><div id='target'><p>" + guild[0].nbmember + "</p></div><div id='target'><p>" + guild[0].points + "</p></div><div id='targetbtn'><button id='attack' value='" + guild[0].id + "'>Attack</button></div></div>");
						}
					);
				}
			},
		),
		'text'
	},
	Wars_Create: function (e) {
		$.post(
			'/wars',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $(e.currentTarget).val(),
				'search' : $("#search").val(),
				'players' : $("#histories_nb_players").val(),
				'points' : $("#histories_points").val(),
				'date_start' : $("#histories_date_start").val(),
				'date_end' : $("#histories_date_end").val(),
				'timeout' : $("#histories_timeout").val(),
				'tournament_id' : $("#histories_tournament_id").val(),
			},
			function (data) 
			{
				if (data == 'error_points')
					notification("error", "Please choose the number of points you want to play for");
				else if (data == 'error_nbplayers')
					notification("error", "Number of players incorrect");
				else if (data == 'error_players')
					notification("error", "You dont have enough players in your team to play");
				else if (data == 'error_startdate')
					notification("error", "Please enter a start date minimum 2 days after today");
				else if (data == 'error_enddate')
					notification("error", "Please enter a end date minimum 2 days after the start");
				else if (data == 'error_tournament')
					notification("error", "Please enter a valid tournament");
				else if (data == 'error_tournament_end')
					notification("error", "The tournament will finish before the war, please change the tournament or the end date of the war.");
				else if (data == 'error_nbpoints')
					notification("error", "Incorrect numbers of points");
				else if (data == 'error_enoughpoint')
					notification("error", "You don't have enough point to play, please change the amount of points");
				else if (data == 'error_timeout')
					notification("error", "Incorrect number of unanswered match");
				else if (data == 'error_noguildfound')
					notification("error", "No guild found, try later.");
				else if (data == 'error_cantbeattacked')
					notification("error", "The guild you wanna attack can't be attacked with those parameters");
				else if (data == 'error_inwar')
					notification("error", "The guild is already in a war");
				else
					window.location.href = "#wars" ;
			},
		),
		'text'
	},
	regular_warMatch_Start: function (e) {
		var tournament_id = $('#war_data').data('tournamentid');
		$.post(
			'/histories/start_game',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"tournament_id": tournament_id,
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
	warMatch_Start: function() {
		var tournament_id = $('#war_data').data('tournamentid');
		var timeout = $('#war_data').data('timeout');
		var war_id = $('#war_data').data('id');
		$.post(
			'/histories/start_game',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"tournament_id": tournament_id,
				"ranked": true, "war_match": true, "war_id": war_id
			},
			function (data) 
			{
				if (data.status == "error")
					notification("error", data.info + " - " + tournament_id);
				else {
					notification("success", "Starting game #" + data.id);
					window.location.href = "#show_game/" + data.id.toString();
				}
			}
		);
	}
});