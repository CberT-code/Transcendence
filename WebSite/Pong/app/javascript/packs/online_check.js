var id = $('#player_data_general').data('id');

import consumer from "../channels/consumer"

var actionCable = consumer.subscriptions.create({ channel: "PresenceChannel", room: id}, {
    connected() {
		console.log("Connected to PresenceChannel, room " + id);	
    },

  disconnected() {
		console.log("Disconnected from PresenceChannel, room " + id);
    },

  received(data) {
		console.log(data);
	}
});

function check_id() {
	console.log("checking id : " + id);
	if (!id) {
		console.log("invalid id");
		id = $('#player_data_general').data('id');
		actionCable.unsubscribe();
	}
	else {
		console.log("valid id : " + id);
		clearInterval(interval_id_check);
		actionCable = consumer.subscriptions.create({ channel: "PresenceChannel", room: id}, {
			connected() {
				console.log("Connected to PresenceChannel, room " + id);	
			},
		
		  disconnected() {
				console.log("Disconnected from PresenceChannel, room " + id);
			},
		
		  received(data) {
				console.log(data);
				$('#notif_banner').html();
				$('#notif_banner').html(data.info);
				$('#notif_banner').css({'background-color' : data.color, 'text-align' : 'center'});
			}
		});
	}

}

var interval_id_check = setInterval(check_id, 1000);