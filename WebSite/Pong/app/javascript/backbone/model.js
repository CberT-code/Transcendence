AccountModel = Backbone.Model.extend({
    urlRoot: "/account/history",
    parse: function (response) {
        console.log("parse !");
        for (var tmp in response) {
            $("#container-history").append("<div id='game'><div id='name'><p>" + response[tmp].target_1 +" " + response[tmp].target_2 + "</p></div><div id='score'><p>socre " + response[tmp].score_target_1 + " " + response[tmp].score_target_2 + " </p></div></div>");
        }
    }
});