function notification(typef, textf) {
    var notification = new Noty({ theme: 'mint', type: typef, text: textf });
    notification.setTimeout(4500);
    notification.show();
    console.log("notif");
}

ViewChannel = Backbone.View.extend(
    {
        el: $(document),
        model: window.app.models.ChannelModel,
        initialize: function () {
        },
        events: {
            'click .CreateaChannel': "CreateaChannel",
            'click .cancelCreateChannel': "cancelCreateChannel",
            'click .submitCreatechannel': "submitCreatechannel",
            "click #channel": "viewChannel",
        },
        viewChannel: function(e) {
            e.preventDefault();
            var id = $($(e.currentTarget).children()[0]).val();
            console.log(id);
            $(".default").css("display", "none");
            $(".channel").css("display", "flex");
            this.model.fetch({"url": "/tchat/channel/get/" + id});
        },
        CreateaChannel: function () {
            $(".default").css("display", "none");
            $(".createChannel").css("display", "flex");
        },
        cancelCreateChannel: function () {
            $(".default").css("display", "flex");
            $(".createChannel").css("display", "none");
        },
        submitCreatechannel: function () {
            if ($(".title").val() != "" && $(".type").val() != "")
                $.post(
                    "/tchat/channel/create",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "title": $(".title").val(),
                        "type": $(".type").val(),
                    },
                    function (data) {
                        if (data == 1) {
                            $(".default").css("display", "flex");
                            $(".createChannel").css("display", "none");
                            notification("success", "Channel created !");
                            Backbone.history.loadUrl();
                        } else
                            notification("error", "A channel have already this title...");
                    },
                    'text'
                );
            else
                notification("error", "Please complete the form...");
        }
    });