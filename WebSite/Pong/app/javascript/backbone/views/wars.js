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
		'click #Accept': 'Accept',
		'click #Decline': 'Decline',
		'click #remove': 'Remove',
		'click #add': 'Add',
		'click #attack': 'Attack',
		'click #save_war': 'SaveWar',
		'change #histories_points': 'Search',
		'change #histories_nb_players': 'Search',
		'keyup #wars_search': 'Wars_Search',

	},
	Accept: function (e) {
		e.preventDefault();
		$.ajax(
			{
				url: '/wars/' + $(e.currentTarget).val(),
				type: 'PATCH',
				data: 
				{
					"id_war":  $(e.currentTarget).val(),
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
	Decline: function (e) {
		e.preventDefault();
		console.log($(e.currentTarget).val());
		$.ajax(
			{
				url: '/wars/' + $(e.currentTarget).val(),
				type: 'DELETE',
				data: 
				{
					"id_war":  $(e.currentTarget).val(),
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
	Add: function (e) {
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
	Remove: function (e) {
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
	Attack: function (e) {
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
					notification("error", "Please choose the number of players");
				else if (data == 'error_3')
					notification("error", "Please enter a start date minimum 2 days after today");
				else if (data == 'error_4')
					notification("error", "Please enter a end date minimum 2 days after the start");
				else if (data == 'error_5')
					notification("error", "Please enter a valid tournament");
				else
				window.location.href = "#wars" ;
			},
		),
		'text'
	},
});