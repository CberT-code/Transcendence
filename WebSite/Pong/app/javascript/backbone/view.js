DeleteAccount = Backbone.View.extend({
    el: $(document),
    initialize: function () {
        console.log("INIT")
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