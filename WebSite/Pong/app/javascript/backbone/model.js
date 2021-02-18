AccountModel = Backbone.Model.extend({
    urlRoot: "/account/history",
    parse: function (response) {
        alert("DATAS : " + response.DATA.responseJSON);
    }
});