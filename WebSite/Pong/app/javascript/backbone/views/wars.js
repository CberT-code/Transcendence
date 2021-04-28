var war_id = $('#war_data').data('id');

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
		'click #warMatch_button' : 'warMatch_Start'
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
						$('#header-wars').attr('onClick',"window.location='/#edit_war/" + data + "'");
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
						$('#header-wars').attr('onClick',"window.location='/#wars'");
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
				'tournament_id' : $("#histories_tournament_id").val(),
			},
			function (data) 
			{
				if (data == 'error_1')
					notification("error", "Please choose the number of points you want to play for");
				else if (data == 'error_2')
					notification("error", "Number of players incorrect");
				else if (data == 'error_3')
					notification("error", "Please enter a start date minimum 2 days after today");
				else if (data == 'error_4')
					notification("error", "Please enter a end date minimum 2 days after the start");
				else if (data == 'error_5')
					notification("error", "Please enter a valid tournament");
				else if (data == 'error_5_2')
					notification("error", "The tournament will finish before the war, please change the tournament or the end date of the war.");
				else if (data == 'error_6')
					notification("error", "Incorrect numbers of points");
				else if (data == 'error_7')
					notification("error", "You don't have enough point to play, please change the amount of points");
				else if (data == 'error_8')
					notification("error", "No guild found, try later.");
				else if (data == 'error_9')
					notification("error", "You dont have enough players in your team to play");
				else if (data == 'error_10')
					notification("error", "The guild you wanna attack can't be attacked with those parameters");
				else if (data == 'error_inwar')
					notification("error", "The guild is already in a war");
				else
					window.location.href = "#wars" ;
			},
		),
		'text'
	},
	warMatch_Start: function() {
		console.log("defying enemy guild to a war match!");
		var tournament_id = $('#war_data').data('tournamentid');
		var timeout = $('#war_data').data('timeout');
		console.log(tournament_id);
		console.log(timeout);
		$.post(
			'/histories/find_or_create',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": tournament_id,
				"ranked": "true", "war_match": "yes", "war_id": war_id,
				"timeout": timeout
			},
			function (data) 
			{
				if (data.status == "error")
					notification("Error", data.info + " - " + tournament_id);
				else {
					notification("Succes", "Starting game #" + data.id);
					window.location.href = "#show_game/" + data.id.toString();
					//do something to notify enemy guild?
				}
			},
		);
	}
});