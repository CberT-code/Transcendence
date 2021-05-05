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
            "click .removeChannelMessage": "removeChannelMessage",
            "click .removeMessage": "removeMessage",
            "click .blockUserChannel": "blockUser",
            "click .cancelPrivateChannel": "cancelPrivChannel",
            "click .submitPrivateChannel": "submitPrivateChannel",
            "click .submitAdminChannel": "submitAdminChannel",
            "click .cancelAdminChannel": "cancelAdminChannel",
            "click .ChannelAdminMode": "UpateChannelType",
            "click .newAdminSubmit": "newAdminSubmit",
            "click .removeChannel": "removeChannel",
            "click .banSwitch": "banSwitch",
            "click .muteSwitch": "muteSwitch",
            "click .cancelSanction": "cancelSanction",
            "click .SanctionSubmit": "SanctionSubmit",
            "click .glbmessage": "viewMessage",
            "keyup .ChannelAdminkey": "UpdateChannelKey",
            "click .CancelConversation": "CancelConversation",
            "click .InitNewConversation": "InitNewConversation",
            "click .submitConversationMessage": "submitConversationMessage",
            "click .blockUser": "blockUser",
            "click #blockMessage": "unblockUser",
            "click .UserInformation": "userInformations",
            "click #userProfil": "cancelUserInformations",
            "click .proposeGame": "duel_game_user",
            "click .removeSanction": "removeSanction",
            "keyup .message": "EntreChannel",
            "keyup .PrivateConvMessage": "EnterPrivate"
        },
		EntreChannel : function(event){
			if(event.keyCode == 13){
				this.$(".submitMessage").click();
			}
		},
        EnterPrivate : function(event){
            if (event.keyCode == 13){
                this.$(".submitConversationMessage").click();
            }
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
        removeChannelMessage: function (e) {
            e.preventDefault();
            var id = $(e.currentTarget).val();
            var key = $(".Channelkey").val();
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
                            $("#messages").empty();
                            $(".message").val("");
                            window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + channel_id + "/" + key });
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
                            notification("error", "You cannot use special characters, you can only use numbers and letters...");
                        }
                    },
                    'text'
                );
        },
        removeChannel: function (e) {
            e.preventDefault();
            var id = $(".Channelid").val();
            if (id != "")
                $.post(
                    "/tchat/channel/remove",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "channel_id": id,
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "Channel removed !");
                            Backbone.history.loadUrl();
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
                            notification("error", "This user is already unmuted...");
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
                            $("#messages").empty();
                            $(".message").val("");
                            window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + id + "/" + key });
                        } else
                            notification("error", "You can't send a message, you are mute from this channel...");
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
                            notification("error", "A channel already has this title...");
                        } else {
                            notification("error", "You cannot use special characters, you can only use numbers and letters...");
                        }
                    },
                    'text'
                );
            else
                notification("error", "Please complete the form...");
        },
        cancelSanction: function () {
            $(".sanctionChannel").css("display", "none");
            $(".default").css("display", "block");
        },
        muteSwitch: function () {
            console.log("MuteSwitch");
            $(".adminChannel").css("display", "none");
            $(".sanctionChannel").css("display", "block");
            $(".sanctionTitle").html("mute - sanction");
            $(".SanctionSubmit").val(2);
            window.app.models.ChannelSanctionsList.fetch({ "url": "/tchat/channel/sanctions/get/" + $(".Channelid").val() + "/2" });
        },
        banSwitch: function () {
            console.log("BanSwitch");
            $(".adminChannel").css("display", "none");
            $(".sanctionChannel").css("display", "block");
            $(".sanctionTitle").html("ban - sanction");
            $(".SanctionSubmit").val(1);
            window.app.models.ChannelSanctionsList.fetch({ "url": "/tchat/channel/sanctions/get/" + $(".Channelid").val() + "/1" });
        },
        SanctionSubmit: function (e) {
            console.log("SanctionSubmit");
            e.preventDefault();
            var type = $(e.currentTarget).val();
            var id = $(".Channelid").val();
            if (type != "" && $(".SanctionTime").val() != "" && $(".SanctionNickname").val() != "" && id != "")
                $.post(
                    "/tchat/channel/sanction/create",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "nickname": $(".SanctionNickname").val(),
                        "type": type,
                        "time": $(".SanctionTime").val(),
                        "id": id
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "The sanction has been applicated !");
                            Backbone.history.loadUrl();
                        } else
                            notification("error", "This user doesn't exist or you cannot make sanction on yoursel...");
                    },
                    'text'
                );
            else
                notification("error", "Please complete the form...");
        },
        viewMessage: function (e) {
            e.preventDefault();
            var id = $($(e.currentTarget).children()[2]).val();
            var username = $($(e.currentTarget).children()[3]).val();
            $(".privateMessages").css("display", "none");
            $(".privateConversation").css("display", "block");
            $(".ConversationWith").html(username);
            $(".PrivateConvTargetId").val(id);
            window.app.models.PrivateConversation.fetch({ "url": "/tchat/message/get/" + id });
        },
        CancelConversation: function () {
            $(".privateMessages").css("display", "block");
            $(".privateConversation").css("display", "none");
            $(".PrivateMessages").empty();
            window.app.models.UpdatePrivateConversations.fetch();
        },
        submitConversationMessage: function () {
            var target_id = $(".PrivateConvTargetId").val();
            var message = $(".PrivateConvMessage").val();
            if (message != "")
                $.post(
                    "/tchat/message/send",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "target_id": target_id,
                        "message": message,
                    },
                    function (data) {
                        if (data == 1) {
                            $(".PrivateMessages").empty();
                            $(".PrivateConvMessage").val("");
                            window.app.models.PrivateConversation.fetch({ "url": "/tchat/message/get/" + target_id });
                        }
                    },
                    'text'
                );
            else
                notification("error", "Please complete the form...");

        },
        removeMessage: function (e) {
            e.preventDefault();
            var message_id = $(e.currentTarget).val();
            var target_id = $(".PrivateConvTargetId").val();
            if (message_id != "")
                $.post(
                    "/tchat/message/remove",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "id": message_id,
                    },
                    function (data) {
                        $(".PrivateMessages").empty();
                        $(".PrivateConvMessage").val("");
                        window.app.models.PrivateConversation.fetch({ "url": "/tchat/message/get/" + target_id });
                    },
                    'text'
                );
            else
                notification("error", "Please complete the form...");

        },
        InitNewConversation: function () {
            var username = $(".UsernameNewConversation").val();
            if (username != "")
                window.app.models.initNewConversation.fetch({ "url": "/tchat/message/init/" + username });
        },
        blockUser: function (e) {
            e.preventDefault();
            var user_id = $(e.currentTarget).val();
            if (user_id != "")
                $.post(
                    "/tchat/message/block",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "user_id": user_id,
                    },
                    function (data) {
                        notification("success", "User blocked !");
                        Backbone.history.loadUrl();
                    },
                    'text'
                );
        },
        unblockUser: function (e) {
            e.preventDefault();
            var user_id = $($(e.currentTarget).children()[2]).val();
            if (user_id != "")
                $.post(
                    "/tchat/message/unblock",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "user_id": user_id,
                    },
                    function (data) {
                        notification("success", "User unblocked !");
                        Backbone.history.loadUrl();
                    },
                    'text'
                );
        },
        userInformations: function (e) {
            e.preventDefault();
            var user_id = $(e.currentTarget).val();
            window.app.models.getProfil.fetch({ "url": "/tchat/profil/get/" + user_id });
            $(".proposeGame").attr("value", user_id);
            $("#userProfil").css("display", "block");
        },
        cancelUserInformations: function() {
            $("#userProfil").css("display", "none");
        },
        removeSanction: function (e) {
            e.preventDefault();
            var id = $(e.currentTarget).val();
            if (id != "")
                $.post(
                    "/tchat/channel/sanction/remove",
                    {
                        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
                        "id": id
                    },
                    function (data) {
                        if (data == 1) {
                            notification("success", "The sanction has been remove !");
                            Backbone.history.loadUrl();
                        }
                    },
                    'text'
                );
        },
        duel_game_user: function (e) {
            var id_opponent = $(e.currentTarget).val();
            $.post(
                '/histories/start_game',
                {
                    'authenticity_token': $('meta[name=csrf-token]').attr('content'),
					"duel": true,
                    "opponent_id": id_opponent
                },
                function (data) 
				{
					if (data.status == "error")
						notification("Error", data.info);
					else
						window.location.href = "#show_game/" + data.id;
				}
            );
        }
    });