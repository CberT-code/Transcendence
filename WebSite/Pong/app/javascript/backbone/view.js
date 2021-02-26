function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
	console.log("notif");
}

ViewAccount = Backbone.View.extend({
	el: $(document),
	events: {
		'click .delete': 'deleteAccount',
		'click .fa-pen': 'SwitchInputOn',
		'click .fa-times-switch': 'SwitchInputOff',
		'click .fa-check': 'EditUsername',
		'click .test': 'HistoryListUser'
	},
	deleteAccount: function () {
		$.post(
			'/account/delete',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content')
			},
			function (data) {
				console.log(data)
			},
			'text'
		);
		window.location.href = "#home";
	},
	SwitchInputOn: function () {
		$(".fa-pen").css("display", "none");
		$(".username_input").css("display", "block");
		$(".username").css("display", "none");
		$(".fa-check").css("display", "block");
		$(".fa-times-switch").css("display", "block");
		console.log("testswitch")
	},
	SwitchInputOff: function () {
		$(".fa-pen").css("display", "block");
		$(".username_input").css("display", "none");
		$(".username").css("display", "flex");
		$(".fa-check").css("display", "none");
		$(".fa-times-switch").css("display", "none");
		console.log("testswitch")
	},
	EditUsername: function () {
		if ($(".username_input").val() != "")
			$.post(
				'/account/changeusername',
				{
					'authenticity_token': $('meta[name=csrf-token]').attr('content'),
					"username": $(".username_input").val()
				},
				function (data) {
					if (data == 1)
						location.reload();
					else
						notification("error", "This username already exist");
				},
				'text'
			);
		else
			notification("error", "Please complete the form...");
    }
});

ViewGuilds = Backbone.View.extend({
    el: $(document),
    initialize: function () {
    },
    events: {
		'click #create': 'CreateGuild',
		'click #quit_guild': 'GuildQuit',
		'click #join_guild': 'JoinGuild',
		'click #declare_war': 'declare_war',
    },
	CreateGuild: function () {
		console.log("testouillet");
		if ($("#guildName").val() == "")
			notification("error", "Please complete the guild name...");
		else if ($("#guildStory").val() == "")
			notification("error", "Please complete the description...");
		else {
			$.post(
				'/guilds',
				{
					'authenticity_token': $('meta[name=csrf-token]').attr('content'),
					"guildname": $("#guild_name").val(),
					"guildstory": $("#guild_description").val(),
					"maxmember": $("#guild_maxmember").val(),
				},
				function (data) {
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
					else{
						$('#header-guild').attr('onClick',"window.location='/#show_guild/" + data + "'");
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
				url: '/guilds/0',
				type: 'DELETE',
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				success: function (data) {
					$('#header-guild').attr('onClick',"window.location='/#guilds'")
					window.location.href = "#guilds";
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
			function (data) {
				if (data == 'error_max')
					notification("error", "Please complete the guild name...");
				$('#header-guild').attr('onClick',"window.location='/#show_guild/" + data + "'");
				window.location.href = "#guilds";
			},
			'text'
		);
	 },
	 declare_war: function () {
		// if ($("#line-war").style.display == 'none')
			$("#line-war").toggle();
		// else
			// $("#line-war").css("display", "none");
	 },
});