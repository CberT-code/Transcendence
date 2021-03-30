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
		'click #join_guild': 'JoinGuild',
		'click #change_admin': 'list_change_admin',
		'click #exec_change_admin': 'exec_change_admin',
    },
	CreateGuild: function () {
		if ($("#guildName").val() == "")
			notification("error", "Please complete the guild name...");
		else if ($("#guildStory").val() == "")
			notification("error", "Please complete the description...");
		else 
		{
			$.post(
				'/guilds',
				{
					'authenticity_token': $('meta[name=csrf-token]').attr('content'),
					"guildname": $("#guild_name").val(),
					"guildstory": $("#guild_description").val(),
					"maxmember": $("#guild_maxmember").val(),
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
						$("#edit_guild_160").css("display", "inline");
						$("#exec_change_admin").css("display", "inline");
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
	JoinGuild: function () {
		$.post(
			'/guilds/join',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#id").val(),
			},
			function (data) 
			{
				if (data == 'error_max')
					notification("error", "Please complete the guild name...");
				if (data == 'error_alreadyinguild')
					notification("error", "You're already in a guild.");
				$('#header-guild').attr('onClick',"window.location='/#show_guild/" + data + "'");
				$("#header-wars").toggle();
				window.location.href = "#guilds";
			},
			'text'
		);
	},
	declare_war: function () {
		
	},
	list_change_admin: function () {
		$("#edit_guild_160").css("display", "inline");
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
});