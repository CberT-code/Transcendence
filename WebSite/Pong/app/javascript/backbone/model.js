AccountModel = Backbone.Model.extend({
    urlRoot: "/account/history",
    parse: function (response) {
        console.log("parse !");
        for (var tmp in response) {
            $("#container-history").append("<div id='game'><div id='name'><p>" + response[tmp].target_1 +" " + response[tmp].target_2 + "</p></div><div id='score'><p>socre " + response[tmp].score_target_1 + " " + response[tmp].score_target_2 + " </p></div></div>");
        }
    }
});

ChannelModel = Backbone.Model.extend({
    parse: function (response) {
        $(".Channeltitle").html(response.title);
        $(".Channelkey").attr("value", response.key);
        $(".submitMessage").attr("value", response.id);
        var id = response.id;
        var key = response.key;
        window.app.models.ChannelMessageModel.fetch({ "url": "/tchat/channel/message/get/" + id + "/" + key });;
    }
});

ChannelMessageModel = Backbone.Model.extend({
    parse: function (response) {
        console.log(response)
    }
});

window.app.models.ChannelMessageModel = new ChannelMessageModel;
window.app.models.ChannelModel = new ChannelModel;