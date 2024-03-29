require("packs/qrcode.js")
function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

ViewAccount = Backbone.View.extend({
	el: $(document),
	events: {
		'click #delete_user': 'DeleteAccount',
		'click #modif_username': 'ModifUsername',
		'click #cancel_modif_username': 'CancelModifUsername',
		'click #confirm_modif_username': 'ConfirmModifUsername',
		'click #user_available': 'UserAvailable',
		'click #add_friend': 'AddFriend',
		'click #del_friend': 'DelFriend',
		'click #duel_game_user': 'duel_game_user',
		'click #watch_game_user': 'watch_game_user',
		'click #ban_user': 'BanUser',
		'click #unban_user': 'UnbanUser',
		'click #otp_enable': 'otp_enable',
		'click #otp_confirm_button': 'otp_confirm',
		'click #otp_disable_button': 'otp_disable',
	},
	DeleteAccount: function () {
		$.ajax(
			{
				url: '/users/' + $("#id").val(),
				type: 'DELETE',
				data: 
				{
					'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				},
				success: function (data) 
				{
					if (data == "error-inguild")
						notification("error", "You need to leave your guild before delete your account");
					else if (data == "error-forbidden")
						notification("error", "Forbidden");
					else{
						notification("success", "Account Deleted");
						window.location.href = "/";
					}
				},
			},
		);
	},
	ModifUsername: function () {
		$(".fa-pen").css("display", "none");
		$(".username_input").css("display", "block");
		$(".username").css("display", "none");
		$(".fa-check").css("display", "block");
		$(".fa-times-switch").css("display", "block");
	},
	CancelModifUsername: function () {
		$(".fa-pen").css("display", "block");
		$(".username_input").css("display", "none");
		$(".username").css("display", "flex");
		$(".fa-check").css("display", "none");
		$(".fa-times-switch").css("display", "none");
	},
	ConfirmModifUsername: function () {
		$.ajax(
			{
				url: '/users/' + $("#id").val(),
				type: 'PATCH',
				data: 
				{
					'authenticity_token': $('meta[name=csrf-token]').attr('content'),
					"username": $(".username_input").val()
				},
				success: function (data) 
				{
					if (data == "success")
						Backbone.history.loadUrl();
					else if (data == "error-incomplete")
						notification("error", "Please complete the form...");
					else if (data == "error-username_exist")
						notification("error", "This username already exist");
					else if (data == "special-characters")
						notification("error", "The username can't contain specials characters.");
					else if (data == "error-size")
						notification("error", "The username is too long: 20 characteres max");
				},
			},
		);	
	},
	UserAvailable: function () {
			$.ajax(
				{
					url: '/users/' + $("#id").val(),
					type: 'PATCH',
					data: 
					{
						'authenticity_token': $('meta[name=csrf-token]').attr('content'),
						"checked": $("#user_available").is(':checked')
					},
					success: function (data) 
					{
						if (data == "success")
							Backbone.history.loadUrl();
						else if (data == "error-forbidden")
							notification("error", "Forbidden");
					},
				},
			);
	},
	AddFriend: function (e) {
		$.post(
			"/users/addfriend/",
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#id").val()
			},
			function (data) {
				if (data == 1) {
					Backbone.history.loadUrl();
				} else {
					notification("error", "You cannot add this player...");
				}
			},
			'text'
		);
	},
	DelFriend: function (e) {
		var id = $(e.currentTarget).val();
		$.post(
			"/users/delfriend/",
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": id,
			},
			function (data) {
				if (data == 1) {
					Backbone.history.loadUrl();
				} else {
					notification("error", "You cannot delete this player...");
				}
			},
			'text'
		);
	},
	duel_game_user: function (e) {
		var id_opponent = $(e.currentTarget).val();
		$.post(
			'/histories/start_game',
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"duel": true,
				"tournament_id": $("#tournaments_end").val(),
				"opponent_id": id_opponent
			},
			function (data) 
			{
				if (data.status == "error")
					notification("error", data.info);
				else
					window.location.href = "#show_game/" + data.id;
			},
		);
	},
	watch_game_user: function (e) {
		var game_id = $(e.currentTarget).val();
		console.log("live game #" + game_id);
		window.location.href = "#show_game/" + game_id ;
	},
	BanUser: function (e) {
		$.post(
			"/users/ban/",
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#id").val()
			},
			function (data) {
				if (data == "error_admin") {
					notification("error", "You cannot ban this player...");
				}
				else if (data == "error-inguild") {
					notification("error", "Please remove this player from his guild first...");
				}
				else if (data == "error-banned") {
					notification("error", "User already banned..");
				} else {
					Backbone.history.loadUrl();
				}
			},
			'text'
		);
	},
	UnbanUser: function (e) {
		$.post(
			"/users/unban/",
			{
				'authenticity_token': $('meta[name=csrf-token]').attr('content'),
				"id": $("#id").val()
			},
			function (data) {
				if (data == "error_admin") {
					notification("error", "You cannot unban this player...");
				} else if (data == "error-unbanned") {
					notification("error", "User already unbanned..");
				}else {
					Backbone.history.loadUrl();
				}
			},
			'text'
		);
	},
	otp_enable: function() {
		var id = $('#content-user #player_data').data('id');
		$.post("/users/enable_otp/" + id.toString(), function(data) {
			if (data.status == "error") {
				console.log(data.info);
				notification("Error", data.info);
			}
			else if (data.status == "ok") {
				console.log(data.info);
				$('#content-user #otp_disable_form').hide();
				$('#content-user #otp_disable_button').hide();
				$('#content-user #otp_confirm_form').show();
				$('#content-user #otp_confirm_button').show();
				$('#content-user #otp_enable').hide();
				$('#content-user #otp_qrcode').show();
				$('#content-user #otp_qrcode').html("");
				$('#content-user #otp_qrcode').qrcode(data.info);
				notification("success", "QRcode generated");
			}
		});
	},	
	otp_disable: function() {
		var id = $('#content-user #player_data').data('id');
		$.post("/users/disable_otp/" + id.toString(), {"otp": $("#content-user #tfa_disable_otp").val()}, function(data) {
			if (data.status == "error") {
				console.log(data.info);
				notification("error", data.info);
			}
			else if (data.status == "ok") {
				$('#content-user #otp_disable_form').hide();
				$('#content-user #otp_disable_button').hide();
				$('#content-user #otp_confirm_form').hide();
				$('#content-user #otp_confirm_button').hide();
				$('#content-user #otp_enable').show();
				$('#content-user #otp_qrcode').hide();
				$('#content-user #qrcode').html("");
				notification("success", data.info);
			}
		});
	},	
	otp_confirm: function() {
		var id = $('#content-user #player_data').data('id');
		$.post("/users/confirm_otp/" + id.toString(), {"otp": $("#content-user #tfa_confirm_otp").val()}, function(data) {
			if (data.status == "error") {
				console.log(data.info);
				notification("error", data.info);
			}
			else if (data.status == "ok") {
				$('#content-user #otp_disable_form').show();
				$('#content-user #otp_disable_button').show();
				$('#content-user #otp_confirm_form').hide();
				$('#content-user #otp_confirm_button').hide();
				$('#content-user #otp_enable').hide();
				$('#content-user #otp_qrcode').hide();
				$('#content-user #qrcode').html("");
				notification("success", data.info);
			}
		});
	}
});
