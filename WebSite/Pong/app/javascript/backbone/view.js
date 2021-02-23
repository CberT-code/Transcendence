function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

ViewAccount = Backbone.View.extend({
	HistoryListUser: function () {
		console.log("Parse !");
		this.model = new AccountModel();
      	this.model.fetch({
          headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
          type: "POST",
      	});
    },
	el: $(document),
	initialize: function() {
		console.log("INIT !");
		this.template = _.template($(document).html());
		this.render();
	},
	render: function() {
		console.log("RENDER");
		this.$el.html(this.template());
		this.HistoryListUser();
		return this;
		// console.log("END INIT !");
		// this.HistoryListUser();
	},
    events: {
		load: 'HistoryListUser',
		'click .delete': 'deleteAccount',
		'click .fa-pen': 'SwitchInputOn',
		'click .fa-times-switch': 'SwitchInputOff',
		'click .fa-check': 'EditUsername',
		'click .test': 'HistoryListUser',
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
    }
});