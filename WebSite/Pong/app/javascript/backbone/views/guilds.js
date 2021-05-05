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
		'click #create_guild': 'Guild_Create',
		'click #quit_guild': 'Guild_Destroy',
		'click #ban_guild': 'Guild_Ban',
		'click #unban_guild': 'Guild_Unban',
		'click #join_guild': 'Guild_Join',
		'click #change_admin': 'list_change_admin',
		'click #exec_change_admin': 'Guild_Update',
		'keyup #guild_search': 'Guild_Search',
		'change #officer_select': 'Guild_Officer',
		'keyup #guilds_anagramme': 'Guild_Anagramme',
    },
	Guild_Create: function () {
		if ($("#guilds_name").val() == "")
			notification("error", "Please complete the guild name...");
		else if ($("#guilds_description").val() == "")
			notification("error", "Please complete the description...");
		else 
		{
			$.post(
				'/guilds',
				{
					'authenticity_token': $('meta[name=csrf-token]').attr('content'),
					"guildname": $("#guilds_name").val(),
					"guildstory": $("#guilds_description").val(),
					"maxmember": $("#guilds_maxmember").val(),
					"anagramme": $("#guilds_anagramme").val(),
				},
				function (data) 
				{
					if (data == 'error-1')
						notification("error", "The guild name can't be empty or contain specials characters or bigger than 20 characters");
					else if (data == 'error-2')
						notification("error", "The guild story can't be empty or contain specials characters");
					else if (data == 'error-3')
						notification("error", "Wrong, max number of member...");
					else if (data == 'error-4')
						notification("error", "This name is already used...");
					else if (data == 'error-5')
						notification("error", "Oversize description...");
					else if (data == 'error-6')
						notification("error", "Anagramme probleme.");
					else if (data == 'error-7')
						notification("error", "The guild anagramme can't be empty or contain specials characters");
					else
						window.location.href = "#show_guild/" + data ;
				},
				'text'
			);
		}
	},
	Guild_Destroy: function () {
		$.ajax(
			{
				url: '/guilds/' + $("#user_id").val(),
				type: 'DELETE',
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				success: function (data)
				{
					if (data.status == "error"){
						notification("error", "Your team needs a leader. Give them a new leader before leaving...");
						$("#guild_id_admin").css("display", "inline");
						$("#exec_change_admin").css("display", "inline");
					}
					else if (data.status == '2'){
						$("#header-wars").toggle();
						Backbone.history.loadUrl();
					}
					else if (data.status == "error-wars"){
						notification("error", "Guild in wars, please wait the end of the war");
					}
					else{
						$('#header-guild').attr('onClick',"window.location='/#guilds'")
						$("#header-wars").toggle();
						window.location.href = "#guilds";
					}
				},
			},
		);
	},
	Guild_Ban: function () {
		$.post(
			'/guilds/ban',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#user_id").val(),
			},
			function (data) 
			{
				if (data == 'error-admin')
				{
					notification("error", "Your team needs a leader. Give them a new leader before leaving...");
					$("#guild_id_admin").css("display", "inline");
					$("#exec_change_admin").css("display", "inline");
				}
				else if (data == "error-one")
				{
					notification("error", "You can't ban if there is only one user.");
				}
				else if (data == "error-yourself")
				{
					notification("error", "You can't ban yourself.");
				}
				else if (data == "error-forbidden")
				{
					notification("error", "forbidden.");
					Backbone.history.loadUrl();
				}
				else
				{
					$('#header-guild').attr('onClick',"window.location='/#guilds'")
					$("#header-wars").toggle();
					Backbone.history.loadUrl();
				}
			},
			'text'
		);
	},
	Guild_Unban: function () {
		$.post(
			'/guilds/unban',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"idguild": $("#guild_id").val(),
				"id": $("#user_id").val(),
			},
			function (data) 
			{
				Backbone.history.loadUrl();
			},
			'text'
		);
	},
	Guild_Join: function () {
		$.post(
			'/guilds/join',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#id").val(),
			},
			function (data) 
			{
				if (data == 'error_banned')
					notification("error", "You've been banned from this guild...");
				else if (data == 'error_max'){
					notification("error", "The team is already full.");
				}
				else if (data == 'error_alreadyinguild')
					notification("error", "You're already in a guild.");
				else {
					$('#header-guild').attr('onClick',"window.location='/#show_guild/" + data + "'");
					$("#header-wars").toggle();
					Backbone.history.loadUrl();
				}

			},
			'text'
		);
	},
	list_change_admin: function () {
		$("#guild_id_admin").css("display", "inline");
		$("#exec_change_admin").css("display", "inline");
	},
	Guild_Update: function () {
		$.ajax(
			{
				url: '/guilds/' + $("#id").val(),
				type: 'PATCH',
				data: 
				{
					"id_admin": $("#guild_id_admin").val(),
					'authenticity_token': $('meta[name=csrf-token]').attr('content')
				},
				success: function (data) 
				{
					if (data == "error-badguild")
						notification("error", "Your not autorize to modify this user");
					else{
						Backbone.history.loadUrl();
						notification("success", "Administrator changed");
					}
				},
			},
		);
	},
	Guild_Search: function (e) {
		$("#guild-list").empty();
		$.post(
			'/guilds/search',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				'search' : $("#guild_search").val(),
			},
			function (data) 
			{
				if (Array.isArray(data)) {
					i = 0;
					data.forEach(
						function(guild) {
							i += 1;
							$("#guild-list").append("<div id='guild'><div id='position'><p>" + i + "</p></div><div id='information'><p>" + guild[0].name + "</p></div><div id='information'><p>" + guild[0].nbmember + "</p></div><div id='action' onClick=\"window.location='/#show_guild/" + guild[0].id +"'\"><p>voir</p></div></div>");
						}
					);
				}
			},
		),
		'text'
	},
	Guild_Officer: function (e) {
		$.post(
			'/guilds/officer',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				'select': $(e.currentTarget).val(),
				"idguild": $("#guild_id").val(),
				"id": $("#user_id").val(),
			},
			function (data) 
			{
				console.log("guild member status change: " + data.status)
				if (data.status == "change ok")
					notification("success", data.user + " role updated to " + data.role);
				else if (data.status == "forbidden")
					notification("error", "Cannot set " + data.user + " to " + data.role);
				else if (data.status == "no change")
					notification("success", data.user + " was already " + data.role);
			},
		),
		'text'
	},
	Guild_Anagramme: function (e) {

		$.post(
			'/guilds/anagramme',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"anagramme": $("#guilds_anagramme").val(),
			},
			function (data) 
			{
				if (data == "toolong"){
					notification("error", "The anagramme is too long");
					$("#guilds_anagramme").css("border", "solid 1px red");
				}
				else if (data == "used"){
					notification("error", "Anagramme already used");
					$("#guilds_anagramme").css("border", "solid 1px red");
				}
				else
					$("#guilds_anagramme").css("border", "solid 1px green");
			},
		);
	},
});