function notification(typef, textf) {
    var notification = new Noty({ theme: 'mint', type: typef, text: textf });
    notification.setTimeout(4500);
    notification.show();
    console.log("notif");
}

AccountModel = Backbone.Model.extend({
    urlRoot: "/account/history",
    parse: function (response) {
        console.log("parse !");
        for (var tmp in response) {
            $("#container-history").append("<div id='game'><div id='name'><p>" + response[tmp].target_1 + " " + response[tmp].target_2 + "</p></div><div id='score'><p>socre " + response[tmp].score_target_1 + " " + response[tmp].score_target_2 + " </p></div></div>");
        }
    }
});

ChannelModel = Backbone.Model.extend({
    parse: function (response) {
        $(".Channeltitle").html(response.title);
        $(".ChannelAdmintitle").html("admin " + response.title);
        $(".ChannelAdminkey").html("KEY" + response.key);
        $(".Channelkey").attr("value", response.key);
        $(".submitMessage").attr("value", response.id);
        var id = response.id;
        var key = response.key;
        window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + id + "/" + key });
    }
});

ChannelMessageModel = Backbone.Model.extend({
    parse: function (response) {
        console.log(response);
        if (Array.isArray(response)) {
            console.log(response[0]);
            if (response[0].admin == 1) {
                $(".submitAdminChannel").css("display", "block");
            }
            response.forEach(function (element) {
                var ret = "<div id='message'><div id='content'><div id='username'><p>" + element.author + " - " + element.date + "</p></div><div id='text'><p>" + element.content + "</p></div></div>";
                if (element.admin == 1) {
                    ret += "<div id='action'><button value='" + element.id + "' class='removeMessage'>remove</button><button value='" + element.author_id + "' class='blockUserChannel'>block</button>";
                    if (element.muted == 1)
                        ret += "<button class='unmuteUserChannel' value='" + element.author_id + "'>unmute</button>";
                    else
                        ret += "<button class='muteUserChannel' value='" + element.author_id + "'>mute</button>";
                    ret += "</div>";
                }
                ret += "</div>";
                $("#messages").append(ret);
            });
        }
    }
});

ChannelAdminBlock = Backbone.Model.extend({
    parse: function (response) {
        if (Array.isArray(response)) {
            response.forEach(function (element) {
                $("#listBlocked").append("<div id='blocked'><div id='username'><p>" + element.username + "</p></div><button class='removeBlocked' value='" + element.user_id + "'>remove</button></div>");
            });
        }
    }
});

ChannelPrivateMessageModel = Backbone.Model.extend({
    parse: function (response) {
        if (response == 2) {
            notification("error", "This key is not correct...");
        } else {
            $(".pvChannel").css("display", "none");
            $(".channel").css("display", "flex");
            $(".Channeltitle").html(response.title);
            $(".Channelkey").attr("value", response.key);
            $(".submitMessage").attr("value", response.id);
            window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + response.id + "/" + response.key });
        }
    }
});

window.app.models.ChannelPrivateMessageModel = new ChannelPrivateMessageModel;
window.app.models.ChannelMessageModel = new ChannelMessageModel;
window.app.models.ChannelModel = new ChannelModel;
window.app.models.ChannelAdminBlock = new ChannelAdminBlock;