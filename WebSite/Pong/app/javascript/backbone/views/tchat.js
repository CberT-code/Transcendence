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
            "click .blockUserChannel": "banUser",
            "click .cancelPrivateChannel": "cancelPrivChannel",
            "click .submitPrivateChannel": "submitPrivateChannel",
            "click .submitAdminChannel": "submitAdminChannel",
            "click .removeBlocked": "unbanUser",
            "click .cancelAdminChannel": "cancelAdminChannel",
            "click .muteUserChannel": "muteUser",
            "click .unmuteUserChannel": "unmuteUser",
            "click .ChannelAdminMode": "UpateChannelType",
            "click .newAdminSubmit": "newAdminSubmit",
            "keyup .ChannelAdminkey": "UpdateChannelKey",
        },
        viewPublicChannel: function (e) {
            e.preventDefault();
            var id = $($(e.currentTarget).children()[0]).val();
            $(".default").css("display", "none");
            $("#messages").empty();
            $(".channel").css("display", "flex");
            this.model.fetch({ "url": "/tchat/channel/get/" + id });
            window.app.models.ChannelisAdmin.fetch({ "url": "/tchat/channel/admin/" + id });
        },
        viewPrivateChannel: function (e) {
            e.preventDefault();
            var id = $($(e.currentTarget).children()[0]).val();
            $(".default").css("display", "none");
            $(".pvChannel").css("display", "flex");
            $("#messages").empty();
            $(".Channelid").val(id);
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
            var id = $(".Channelid").val();
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
            var id = $(".Channelid").val();
            window.app.models.ChannelAdminBlock.fetch({ "url": "/tchat/channel/blocked/" + id });
        },
        newAdminSubmit: function () {
            if ($(".newAdmin").val() != "" && $(".Channelid").val() != "")
                $.post(
                    "/tchat/channel/admin/swap",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "newAdmin": $(".newAdmin").val(),
                        "channel_id": $(".Channelid").val()
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "Channel admin role exchange !");
                            Backbone.history.loadUrl();
                        } else {
                            notification("error", "This user doesn't exist...");
                        }
                    },
                    'text'
                );
            else
                notification("error", "Please complete the form...");
        },
        removeMessage: function (e) {
            e.preventDefault();
            var id = $(e.currentTarget).val();
            var channel_id = $(".Channelid").val();
            if (channel_id != "")
                $.post(
                    "/tchat/channel/message/remove",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "channel_id": channel_id,
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
        banUser: function (e) {
            e.preventDefault();
            var target_id = $(e.currentTarget).val()
            var channel_id = $(".Channelid").val();
            var key = $(".Channelkey").val();
            if (channel_id != "" && key != "")
                $.post(
                    "/tchat/channel/sanction/",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "channel_id": channel_id,
                        "target_id": target_id,
                        "type": 1
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User banned !");
                            Backbone.history.loadUrl();
                        } else {
                            notification("error", "You cannot ban yourself...");
                        }
                    },
                    'text'
                );
        },
        unbanUser: function (e) {
            e.preventDefault();
            var target_id = $(e.currentTarget).val()
            var channel_id = $(".Channelid").val();
            var key = $(".Channelkey").val();
            if (channel_id != "" && key != "")
                $.post(
                    "/tchat/channel/sanction/",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "channel_id": channel_id,
                        "target_id": target_id,
                        "type": 2
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User is unbanne !");
                            Backbone.history.loadUrl();
                        }
                    },
                    'text'
                );
        },
        muteUser: function (e) {
            e.preventDefault();
            var target_id = $(e.currentTarget).val()
            var channel_id = $(".Channelid").val();
            var key = $(".Channelkey").val();
            if (channel_id != "" && key != "")
                $.post(
                    "/tchat/channel/sanction/",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "channel_id": channel_id,
                        "target_id": target_id,
                        "type": 3
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User muted !");
                            Backbone.history.loadUrl();
                        } else {
                            notification("error", "You cannot mute yourself...");
                        }
                    },
                    'text'
                );
        },
        unmuteUser: function (e) {
            e.preventDefault();
            var target_id = $(e.currentTarget).val()
            var channel_id = $(".Channelid").val();
            var key = $(".Channelkey").val();
            if (channel_id != "" && key != "")
                $.post(
                    "/tchat/channel/sanction/",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "channel_id": channel_id,
                        "target_id": target_id,
                        "type": 4
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User is unmute !");
                            Backbone.history.loadUrl();
                        }
                    },
                    'text'
                );
        },
        UpdateChannelKey: function (e) {
            e.preventDefault();
            var key = $(e.currentTarget).val();
            var id = $(".Channelid").val();
            if (key != "" && id != "")
                $.post(
                    "/tchat/channel/key",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "key": key,
                        "id": id,
                    },
                    function (data) {
                        if (data == 2) {
                            notification("error", "You cannot use specials characters, you can only use numbers and letters...");
                        }
                    },
                    'text'
                );
        },
        unmuteUserChannel: function (e) {
            var id = $(e.currentTarget).val();
            var channelId = $(".Channelid").val();
            if (id != "" && channelId != "")
                $.post(
                    "/tchat/channel/user",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "channelId": channelId,
                        "id": id,
                        "type": 3
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "User unmuted !");
                            Backbone.history.loadUrl();
                        } else if (data == 2)
                            notification("error", "This user is already unmute...");
                        else
                            notification("error", "You cannot unmute yourself...");
                    },
                    'text'
                );
        },
        UpateChannelType: function (e) {
            var channelId = $(".Channelid").val();
            if (channelId != "")
                $.post(
                    "/tchat/channel/type",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "channelId": channelId,
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "Channel type updated !");
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
                        } else if (data == 2) {
                            notification("error", "A channel have already this title...");
                        } else {
                            notification("error", "You cannot use specials characters, you can only use numbers and letters...");
                        }
                    },
                    'text'
                );
            else
                notification("error", "Please complete the form...");
        }
    });