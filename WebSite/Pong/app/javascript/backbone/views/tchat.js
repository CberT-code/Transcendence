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
            "click .publicChannel": "viewPublicChannel",
            "click .privateChannel": "viewPrivateChannel",
            "click .cancelMessage": "cancelChannel",
            "click .submitMessage": "submitMessage",
            "click .removeMessage": "removeMessage",
            "click .blockUserChannel": "blockUserChannel",
            "click .cancelPrivateChannel": "cancelPrivChannel",
            "click .submitPrivateChannel": "submitPrivateChannel",
            "click .submitAdminChannel": "submitAdminChannel",
            "click .removeBlocked": "removeBlocked",
            "click .cancelAdminChannel": "cancelAdminChannel",
            "click .muteUserChannel": "muteUserChannel",
            "click .unmuteUserChannel": "unmuteUserChannel",
        },
        viewPublicChannel: function (e) {
            e.preventDefault();
            var id = $($(e.currentTarget).children()[0]).val();
            $(".default").css("display", "none");
            $("#messages").empty();
            $(".channel").css("display", "flex");
            this.model.fetch({ "url": "/tchat/channel/get/" + id });
        },
        viewPrivateChannel: function (e) {
            e.preventDefault();
            var id = $($(e.currentTarget).children()[0]).val();
            $(".default").css("display", "none");
            $(".pvChannel").css("display", "flex");
            $("#messages").empty();
            $(".privateChannelId").val(id);
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
            $(".submitAdminChannel").css("display", "none");
            $("#messages").empty();
        },
        cancelAdminChannel: function () {
            $(".default").css("display", "flex");
            $(".adminChannel").css("display", "none");
            $(".submitAdminChannel").css("display", "none");
        },
        cancelPrivChannel: function () {
            $(".default").css("display", "flex");
            $(".pvChannel").css("display", "none");
        },
        submitPrivateChannel: function () {
            var key = $(".key").val();
            var id = $(".privateChannelId").val();
            if (key != "" && id != "")
                window.app.models.ChannelPrivateMessageModel.fetch({ "url": "/tchat/channel/get/" + id + "/" + key });
            else
                notification("error", "Please complete the form...");

        },
        submitAdminChannel: function () {
            $(".channel").css("display", "none");
            $(".adminChannel").css("display", "block");
            $("#messages").empty();
            $("#listBlocked").empty();
            var key = $(".Channelkey").val();
            window.app.models.ChannelAdminBlock.fetch({ "url": "/tchat/channel/blocked/" + key });
        },
        removeMessage: function (e) {
            e.preventDefault();
            var id = $(e.currentTarget).val();
            var key = $(".Channelkey").val();
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
        removeBlocked: function (e) {
            e.preventDefault();
            var id = $(e.currentTarget).val();
            var key = $(".Channelkey").val();
            if (id != "" && key != "")
                $.post(
                    "/tchat/channel/blocked/" + key,
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "id": id,
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User removed !");
                            Backbone.history.loadUrl();
                        }
                    },
                    'text'
                );
        },
        blockUserChannel: function (e) {
            var id = $(e.currentTarget).val();
            var key = $(".Channelkey").val();
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
                        } else if (data == 2)
                            notification("error", "This user is already block...");
                        else
                            notification("error", "You cannot block yourself...");
                    },
                    'text'
                );
        },
        muteUserChannel: function (e) {
            var id = $(e.currentTarget).val();
            var key = $(".Channelkey").val();
            if (id != "" && key != "")
                $.post(
                    "/tchat/channel/user",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "key": key,
                        "id": id,
                        "type": 2
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User muted !");
                            Backbone.history.loadUrl();
                        } else if (data == 2)
                            notification("error", "This user is already mute...");
                        else
                            notification("error", "You cannot mute yourself...");
                    },
                    'text'
                );
        },
        unmuteUserChannel: function (e) {
            var id = $(e.currentTarget).val();
            var key = $(".Channelkey").val();
            if (id != "" && key != "")
                $.post(
                    "/tchat/channel/user",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "key": key,
                        "id": id,
                        "type": 3
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User muted !");
                            Backbone.history.loadUrl();
                        } else if (data == 2)
                            notification("error", "This user is already mute...");
                        else
                            notification("error", "You cannot mute yourself...");
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
                        } else
                            notification("error", "You can't send a message, you are blocked from this channel...");
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