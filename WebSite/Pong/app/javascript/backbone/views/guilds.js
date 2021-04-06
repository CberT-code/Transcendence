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
		'click #create_guild': 'CreateGuild',
		'click #quit_guild': 'GuildQuit',
		'click #ban_guild': 'GuildBan',
		'click #unban_guild': 'GuildUnban',
		'click #join_guild': 'JoinGuild',
		'click #change_admin': 'list_change_admin',
		'click #exec_change_admin': 'exec_change_admin',
		'change #officer_select': 'OfficerSelect',
		'keyup #guild_search': 'Guild_Search',
		'keyup #guilds_anagramme': 'Check_Anagramme',
    },
	CreateGuild: function () {
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
						notification("error", "Please complete the guild name...");
					else if (data == 'error-2')
						notification("error", "Please complete the description...");
					else if (data == 'error-3')
						notification("error", "Wrong, max number of member...");
					else if (data == 'error-4')
						notification("error", "This name is already used...");
					else if (data == 'error-5')
						notification("error", "Oversize description...");
					else if (data == 'error-6')
						notification("error", "Anagramme probleme.");
					else
					{
						$('#header-guild').attr('onClick',"window.location='/#show_guild/" + data + "'");
						$("#header-wars").toggle();
						window.location.href = "#show_guild/" + data ;
					}
				},
				'text'
			);
		}
	},
	GuildQuit: function () {
		$.ajax(
			{
				url: '/guilds/' + $("#id").val(),
				type: 'DELETE',
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				success: function (data)
				{
					if (data == 'error-admin')
					{
						notification("error", "Your team needs a leader. Give them a new leader before leaving...");
						$("#guild_id_admin").css("display", "inline");
						$("#exec_change_admin").css("display", "inline");
					}
					else if (data == 2)
					{
						$("#header-wars").toggle();
						Backbone.history.loadUrl();
					}
					else
					{
						$('#header-guild').attr('onClick',"window.location='/#guilds'")
						$("#header-wars").toggle();
						window.location.href = "#guilds";
					}
				},
			},
		);
	},
	GuildBan: function () {
		$.post(
			'/guilds/ban',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#id").val(),
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
	GuildUnban: function () {
		$.post(
			'/guilds/unban',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"idguild": $("#guild_id").val(),
				"id": $("#id").val(),
			},
			function (data) 
			{
				Backbone.history.loadUrl();
			},
			'text'
		);
	},
	JoinGuild: function () {
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
	exec_change_admin: function () {
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
					window.location.href = "#show_guild/" + data ;
					notification("success", "Administrator changed");
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
	OfficerSelect: function (e) {
		$.post(
			'/guilds/officer',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				'select': $(e.currentTarget).val(),
				"idguild": $("#guild_id").val(),
				"id": $("#id").val(),
			},
			function (data) 
			{
				if (data == "changed ok")
					notification("success", "Changement ok");
				if (data == "forbidden")
					notification("error", "forbidden");
			},
		),
		'text'
	},
	Check_Anagramme: function (e) {

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