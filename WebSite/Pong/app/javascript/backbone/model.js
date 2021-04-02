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
        $(".ChannelAdminkey").append(response.key);
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
            console.log(response[0][0]);
            if (response[0][0].admin == 1) {
                $(".submitAdminChannel").css("display", "block");
            }
            response.forEach(function (element) {
                if (element[0].admin == 1)
                    $("#messages").append("<div id='message'><div id='content'><div id='username'><p>" + element[0].author + " - " + element[0].date + "</p></div><div id='text'><p>" + element[0].content + "</p></div></div><div id='action'><button value='" + element[0].id + "' class='removeMessage'>remove</button><button value='" + element[0].author_id + "' class='blockUserChannel'>block</button><button value='" + element[0].author_id + "' class='muteUserChannel'>mute</button></div></div>");
                else
                    $("#messages").append("<div id='message'><div id='content'><div id='username'><p>" + element[0].author + " - " + element[0].date + "</p></div><div id='text'><p>" + element[0].content + "</p></div></div></div>");
            });
        }
    }
});

ChannelAdminBlock = Backbone.Model.extend({
    parse: function (response) {
        if (Array.isArray(response)) {
           response.forEach(function (element) {
            $("#listBlocked").append("<div id='blocked'><div id='username'><p>"+ element.username +"</p></div><button class='removeBlocked' value='"+ element.user_id +"'>remove</button></div>");
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