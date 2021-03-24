function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

ViewWars = Backbone.View.extend(
{
    el: $(document),
    initialize: function () {
    },
    events: {
		'click #war_zone': 'WarZone',
    },
});