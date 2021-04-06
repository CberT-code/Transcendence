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

// SearchGuildForWarModel = Backbone.Model.extend({
//     parse: function (response) {
//         console.log(response);
//         if (Array.isArray(response)) {
// 			i = 0;
//             response.forEach(
// 				function(guild) {
// 					console.log("ici i = " + i);
// 					i += 1;
// 					$("#corp").append("<div class='war'><div id='position'><p>" + i + "</p></div><div id='target'><p>" + guild[0].name + "</p></div><div id='target'><p>" + guild[0].nbmember + "</p></div><div id='target'><p>" + guild[0].points + "</p></div><div id='targetbtn'><button id='attack' value='" + guild[0].id + "'>Attack</button></div></div>");
// 				}
// 			);
//         }
//     }
// });

window.app.models.ChannelMessageModel = new ChannelMessageModel;
window.app.models.ChannelModel = new ChannelModel;
// window.app.models.SearchGuildForWarModel = new SearchGuildForWarModel;