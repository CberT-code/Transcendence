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
        if (response.type_channel == 1) {
            $(".ChannelAdminMode").html("change to public");
        } else {
            $(".ChannelAdminMode").html("change to private");
        }
        var id = response.id;
        var key = response.key;
        window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + id + "/" + key });
    }
});

ChannelisAdmin = Backbone.Model.extend({
    parse: function (response) {
        if (response == "1")
            $(".submitAdminChannel").css("display", "block");
    }
});

ChannelMessageModel = Backbone.Model.extend({
    parse: function (response) {
        if (response && response.length > 0 && Array.isArray(response)) {
            response.forEach(function (element) {
                var ret = "<div id='message'><div id='content'><div id='username'><button class='UserInformation' value='"+ element.author_id +"' >" + element.author + " - " + element.date + "</button></div><div id='text'><p>" + element.content + "</p></div></div>";
                if (element.admin == 1) {
                    ret += "<div id='action'><button value='" + element.id + "' class='removeChannelMessage'>remove</button>";
                    if (element.blocked == 1 && element.own == 2)
                        ret += "<button class='unblockUserChannel' value='" + element.author_id + "'>unban</button>";
                    if (element.muted == 1 && element.own == 2)
                        ret += "<button class='unmuteUserChannel' value='" + element.author_id + "'>unmute</button>";
                    if (element.own == 2)
                        ret += "<button class='blockUser' value='" + element.author_id + "'>block</button>";
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
            console.log("check private " + response.type_channel);
            if (response.type_channel == 1)
                $(".ChannelAdminMode").html("change to public");
            else
                $(".ChannelAdminMode").html("change to private");
            window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + response.id + "/" + response.key });
        }
    }
});

ChannelSanctionsList = Backbone.Model.extend({
    parse: function (response) {
        $("#sanctionList").html("")
        if (response && response.length > 0 && Array.isArray(response)) {
            response.forEach(function (element) {
                var ret = "";
                ret += "<div id='sanction'><div id='username'><p>";
                ret += element.nickname + "</p></div>";
                ret += "<button value='"+ element.id +"' class='removeSanction'>Remove</button>";
                $("#sanctionList").append(ret);
            });
        }
    }
});

PrivateConversation = Backbone.Model.extend({
    parse: function (response) {
        if (response.length > 0 && Array.isArray(response)) {
            response.forEach(function (element) {
                var ret = "<div id='message'><div id='content'><div id='username'><button class='UserInformation' value='"+ element.author_id +"'>" + element.author + " - " + element.date + "</button></div><div id='text'><p>" + element.content + "</p></div></div><div id='action'>";
                if (element.admin == 1) {
                    ret += "<button value='" + element.id + "' class='removeMessage'>remove</button>";
                }
                if (element.block == 1) {
                    ret += "<button value='" + element.author_id + "' class='blockUser'>block</button>";
                }
                ret += "</div></div>";
                $(".PrivateMessages").append(ret);
            });
        }
    }
});

initNewConversation = Backbone.Model.extend({
    parse: function (response) {
        if (response == "2") {
            notification("error", "This username doesn't exist...");
        } else if (response == "3") {
            notification("error", "You cannot speak with yourself...");
        } else {
            var username = response.nickname;
            var id = response.id;
            $(".privateMessages").css("display", "none");
            $(".privateConversation").css("display", "block");
            $(".ConversationWith").html(username);
            $(".PrivateConvTargetId").val(id);
        }
    }
});

getProfil = Backbone.Model.extend({
    parse: function(response) {
        console.log(response);
        if (response != "") {
            $(".UserIcon").attr("src", response.image);
            $(".UserTitle").html(response.username);
            $("#informations").empty();
            if (response.guild != 0) {
                $("#informations").append("<div id='information'><p>Guild : "+ response.guild.name +"</p></div>");
            }
            $("#informations").append("<div id='information'><p>Victory : "+ response.stats.victory +"</p></div>");
            $("#informations").append("<div id='information'><p>Defeat : "+ response.stats.defeat +"</p></div>");
        }
    }
})

UpdatePrivateConversations = Backbone.Model.extend({
    "url": "tchat/messages/private",
    parse: function(response) {
        if (response.length > 0) {
            $(".listConversations").html("");
            response.forEach(function (element) {
                var ret = "";
                if (element.blocked == 1) {
                    ret += "<div id='message' class='glbmessage'><div id='icon'>"
                    ret += "<img src='"+ element.image +"' alt='user icon'></div><div id='username'>"
                    ret += "<p>"+ element.nickname +"</p></div>" 
                    ret += "<input type='hidden' value='" + element.target_id+ "'>"
                    ret += "<input type='hidden' value='" + element.nickname+ "'>"
                } else {
                    ret += "<div id='blockMessage' class='glbmessage'><div id='icon'>"
                    ret += "<img src='"+ element.image +"' alt='user icon'></div><div id='username'>"
                    ret += "<p>"+ element.nickname +"</p></div>" 
                    ret += "<input type='hidden' value='" + element.target_id+ "'>"
                }
                $(".listConversations").append(ret);
            });
        }
    }
})

window.app.models.UpdatePrivateConversations = new UpdatePrivateConversations;
window.app.models.getProfil = new getProfil;
window.app.models.initNewConversation = new initNewConversation;
window.app.models.PrivateConversation = new PrivateConversation;
window.app.models.ChannelPrivateMessageModel = new ChannelPrivateMessageModel;
window.app.models.ChannelisAdmin = new ChannelisAdmin;
window.app.models.ChannelMessageModel = new ChannelMessageModel;
window.app.models.ChannelModel = new ChannelModel;
window.app.models.ChannelAdminBlock = new ChannelAdminBlock;
window.app.models.ChannelSanctionsList = new ChannelSanctionsList;