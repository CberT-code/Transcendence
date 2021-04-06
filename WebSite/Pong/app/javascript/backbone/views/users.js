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
					else
						notification("success", "Account Deleted");
				},
			},
		);
		window.location.href = "#home";
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
					},
				},
			);
    },
});