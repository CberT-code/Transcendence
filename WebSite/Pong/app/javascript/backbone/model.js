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
        console.log(response);
        if (Array.isArray(response)) {
            response.forEach(function(element) {
                if (element[0].admin == 1)
                    $("#messages").append("<div id='message'><div id='content'><div id='username'><p>"+ element[0].author +" - "+ element[0].date +"</p></div><div id='text'><p>"+ element[0].content  +"</p></div></div><div id='action'><button value='"+ element[0].id +"' class='removeMessage'>remove</button><button value='"+ element[0].author_id +"' class='block'>block</button></div></div>");
                else
                    $("#messages").append("<div id='message'><div id='content'><p>"+ element[0].content  +"</p></div><div id='info'><p>"+ element[0].author +"</p></div></div>");
            });
        }
    }
});

SearchGuildWarModel = Backbone.Model.extend({
    parse: function (response) {
        $("#histories_nb_players").attr("value", response.nb_players);
        $("#search").attr("value", response.search);
        var search = response.search;
        var nb_player = response.nb_players;
        window.app.models.ChannelMessageModel.fetch({ "url": "/wars/search/" + nb_player + "/" + search });;
    }
});

SearchGuildForWarModel = Backbone.Model.extend({
    parse: function (response) {
        console.log(response);
        if (Array.isArray(response)) {
            response.forEach(function(element) {
                if (element[0].admin == 1)
                    $("#messages").append("<div id='message'><div id='content'><div id='username'><p>"+ element[0].author +" - "+ element[0].date +"</p></div><div id='text'><p>"+ element[0].content  +"</p></div></div><div id='action'><button value='"+ element[0].id +"' class='removeMessage'>remove</button><button value='"+ element[0].author_id +"' class='block'>block</button></div></div>");
                else
                    $("#messages").append("<div id='message'><div id='content'><p>"+ element[0].content  +"</p></div><div id='info'><p>"+ element[0].author +"</p></div></div>");
            });
        }
    }
});

window.app.models.ChannelMessageModel = new ChannelMessageModel;
window.app.models.ChannelModel = new ChannelModel;