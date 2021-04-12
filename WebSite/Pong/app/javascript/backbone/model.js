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
            $("#container-history").append("<div id='game'><div id='name'><p>" + response[tmp].host_id + " " + response[tmp].opponent_id + "</p></div><div id='score'><p>socre " + response[tmp].score_host_id + " " + response[tmp].score_opponent_id + " </p></div></div>");
        }
    }
});

ChannelModel = Backbone.Model.extend({
    parse: function (response) {
        $(".Channeltitle").html(response.title);
        $(".ChannelAdmintitle").html("admin " + response.title);
        $(".ChannelAdminkey").val(response.key);
        $(".Channelkey").attr("value", response.key);
        $(".Channelid").attr("value", response.id);
        $(".submitMessage").attr("value", response.id);
        if (response.type_channel == 1)
            $(".ChannelAdminMode").html("change to private");
        else
            $(".ChannelAdminMode").html("change to public");
        var id = response.id;
        var key = response.key;
        window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + id + "/" + key });
    }
});

ChannelisAdmin = Backbone.Model.extend({
    parse: function(response) {
        if (response == "1")
            $(".submitAdminChannel").css("display", "block");
    }
});

ChannelMessageModel = Backbone.Model.extend({
    parse: function (response) {
        console.log(response);
        if (response && response.length > 0 && Array.isArray(response)) {
            response.forEach(function (element) {
                var ret = "<div id='message'><div id='content'><div id='username'><p>" + element.author + " - " + element.date + "</p></div><div id='text'><p>" + element.content + "</p></div></div>";
                if (element.admin == 1) {
                    ret += "<div id='action'><button value='" + element.id + "' class='removeMessage'>remove</button>";
                    if (element.blocked == 1)
                        ret += "<button class='unblockUserChannel' value='" + element.author_id + "'>unban</button>";
                    else
                        ret += "<button class='blockUserChannel' value='" + element.author_id + "'>ban</button>";
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
                $("#listBlocked").append("<div id='blocked'><div id='username'><p>" + element.username + "</p></div><button class='removeBlocked' value='" + element.user_id + "'>UnBlock</button></div>");
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
            console.log(response);
            if (response.type_channel == "1")
                $(".ChannelAdminMode").html("change to public");
            else
                $(".ChannelAdminMode").html("change to private");
            window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + response.id + "/" + response.key });
        }
    }
});

window.app.models.ChannelPrivateMessageModel = new ChannelPrivateMessageModel;
window.app.models.ChannelisAdmin = new ChannelisAdmin;
window.app.models.ChannelMessageModel = new ChannelMessageModel;
window.app.models.ChannelModel = new ChannelModel;
window.app.models.ChannelAdminBlock = new ChannelAdminBlock;