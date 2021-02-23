function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
	console.log("notif");
}

ViewAccount = Backbone.View.extend({
	el: $(document),
	initialize: function () {
		console.log(document);
		$(document).find("#container-history").append("<p>1</p>");
		// console.log($(document).html());
		this.model = new AccountModel();
		this.model.fetch({
			headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
			type: "POST",
			success: function(response) {
			}
		});
	},
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
    },
	HistoryListUser: function () {
		$.post(
			'/account/history',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
			},
			function (data) {
				console.log(data);
				alert(data);
			},
			'text'
		);
    }
});

ViewGuilds = Backbone.View.extend({
    el: $(document),
    initialize: function () {

    },
    events: {
		'click .create': 'CreateGuild',
		'click .quit_guild': 'GuildQuit'
    },
	CreateGuild: function () {
		console.log("testouillet");
		if ($("#guildName").val() == "")
			notification("error", "Please complete the guild name...");
		else if ($("#guildStory").val() == "")
			notification("error", "Please complete the description...");
		else {
			$.post(
				'/guilds/guildcreate',
				{
					'authenticity_token': $('meta[name=csrf-token]').attr('content'),
					"guildname": $("#guildName").val(),
					"guildstory": $("#guildStory").val(),
					"maxmember": $("#maxMember").val(),
				},
				function (data) {
					if (data == 1){
						window.location.href = "#guilds";
					}
					else if (data == 2)
						notification("error", "Please complete the guild name...");
					else if (data == 3)
						notification("error", "Please complete the description...");
					else if (data == 4)
						notification("error", "Wrong, max number of member...");
					else if (data == 5)
						notification("error", "This name is already used...");
					else if (data == 6)
						notification("error", "Oversize description...");
			},
			'text'
			);
		}
	},
	GuildQuit: function () {
		$.post(
			'/guilds/guildquit',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
			},
			function (data) {
				location.reload();
			},
			'text'
		);
	 }
});