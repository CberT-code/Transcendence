DeleteAccount = Backbone.View.extend({
    el: $(document),
    initialize: function () {
        console.log("TOKEN " + $('meta[name=csrf-token]').attr('content'));
        this.model = new AccountModel();
        this.model.fetch({
            headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
            type: "POST",
            success: function(response) {
				console.log("sucess");
			},
            error: function(err) {
                console.log("error");
                console.log(err);
            }
        });
    },
    events: {
        'click .delete': 'deleteAccount'
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
    }
});