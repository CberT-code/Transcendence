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
            "click .cancelMessage": "cancelChannel",
            "click .submitMessage": "submitMessage",
            "click .removeMessage": "removeMessage",
            "click .blockUserChannel": "blockUserChannel",
        },
        viewChannel: function (e) {
            e.preventDefault();
            var id = $($(e.currentTarget).children()[0]).val();
            $(".default").css("display", "none");
            $(".channel").css("display", "flex");
            this.model.fetch({ "url": "/tchat/channel/get/" + id });
        },
        CreateaChannel: function () {
            $(".default").css("display", "none");
            $(".createChannel").css("display", "flex");
        },
        cancelCreateChannel: function () {
            $(".default").css("display", "flex");
            $(".createChannel").css("display", "none");
        },
        cancelChannel: function () {
            $(".default").css("display", "flex");
            $(".channel").css("display", "none");
            $("#messages").empty();
        },
        removeMessage: function (e) {
            e.preventDefault();
            var id = $(e.currentTarget).val();
            var key = $(".Channelkey").val();
            console.log(id);
            if (key != "")
                $.post(
                    "/tchat/channel/message/remove",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "key": key,
                        "id": id,
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "Message remove !");
                            Backbone.history.loadUrl();
                        }
                    },
                    'text'
                );
        },
        blockUserChannel: function (e) {
            var id = $(e.currentTarget()).val();
            var key = $(".ChannelKey").val();
            if (id != "" && key != "")
                $.post(
                    "/tchat/channel/user",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "key": key,
                        "id": id,
                        "type": 1
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User blocked !");
                            Backbone.history.loadUrl();
                        }
                    },
                    'text'
                );
        },
        submitMessage: function (e) {
            e.preventDefault();
            var id = $(".submitMessage").val();
            var key = $(".Channelkey").val();
            var message = $(".message").val();
            if (message != "" && id != "" && key != "")
                $.post(
                    "/tchat/channel/message/create",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "key": key,
                        "id": id,
                        "message": message,
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "Message send !");
                            Backbone.history.loadUrl();
                        }
                    },
                    'text'
                );
            else
                notification("error", "Please complete the form...");
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