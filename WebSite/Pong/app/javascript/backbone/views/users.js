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
		'click #available': 'Available',
		
	},
	deleteAccount: function (ev) {
		console.log(ev.currentTarget.data("id"));
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
						console.log("Account Deleted")
				},
			},
		);
		window.location.href = "#home";
	},
	SwitchInputOn: function () {
		$(".fa-pen").css("display", "none");
		$(".username_input").css("display", "block");
		$(".username").css("display", "none");
		$(".fa-check").css("display", "block");
		$(".fa-times-switch").css("display", "block");
	},
	SwitchInputOff: function () {
		$(".fa-pen").css("display", "block");
		$(".username_input").css("display", "none");
		$(".username").css("display", "flex");
		$(".fa-check").css("display", "none");
		$(".fa-times-switch").css("display", "none");
	},
	EditUsername: function () {
		if ($(".username_input").val() != "")
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
						if (data == 1)
							location.reload();
						else if (data == "error-forbidden")
							notification("error", "Forbidden");
						else
							notification("error", "This username already exist");
					},
				},
			);
		else
			notification("error", "Please complete the form...");
	},
	Available: function () {
			$.ajax(
				{
					url: '/users/' + $("#id").val(),
					type: 'PATCH',
					data: 
					{
						'authenticity_token': $('meta[name=csrf-token]').attr('content'),
						"checked": $("#available").is(':checked')
					},
					success: function (data) 
					{
						if (data == 1)
							location.reload();
						else if (data == "error-forbidden")
							notification("error", "Forbidden");
						else
							notification("error", "This username already exist");
					},
				},
			);
    },
});