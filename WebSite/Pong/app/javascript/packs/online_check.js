var id = $('#player_data').data('id');

import consumer from "../channels/consumer"

var actionCable = consumer.subscriptions.create({ channel: "PresenceChannel", room: id}, {
    connected() {
		console.log("Connected to Online_check, room " + id);	
    },

  disconnected() {
		console.log("Disconnected from Online_check, room " + id);
    },

  received(data) {

	}
});