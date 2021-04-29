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
				if (data.type == "duel") {
					$('#notif_banner').off('click');
					$('#notif_banner').click(function(){
						window.location='/#show_game/' + data.id;
						$('#notif_banner').off('click');
						$('#notif_banner').html();
					  });
				}
				else if (data.type == "warTimeNotif") {
					$('#notif_banner').off('click');
					$('#notif_banner').click(function(){
						window.location.href = '/#show_war/' + data.id;
						$('#notif_banner').off('click');
						$('#notif_banner').html();
					  });
				}
				else if (data.type == "warMatchRequest") {
					$('#notif_banner').off('click');
					$('#notif_banner').click(function(){
						$.post(
							'/histories/joinWarMatch',
							{
								'authenticity_token': $('meta[name=csrf-token]').attr('content'),
								"war_id": data.war_id,
								"game_id": data.id
							},
							function (game) 
							{
								if (game.status == "error")
									notification("error", game.info);
								else {
									notification("succes", "Starting game #" + data.id);
									window.location.href = "#show_game/" + data.id.toString();
								}
							}
						);
					})
				}
			}
		});
	}

}

var interval_id_check = setInterval(check_id, 1000);