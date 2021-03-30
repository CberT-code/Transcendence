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
});