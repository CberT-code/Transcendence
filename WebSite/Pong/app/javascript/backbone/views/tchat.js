ViewGuilds = Backbone.View.extend(
    {
        el: $(document),
        initialize: function () {
        },
        events: {
            'click .createChannel': "CreateChannel",
        },
        CreateChannel: function () {
            console.log("CREATE CHANNEL");
        },
    });