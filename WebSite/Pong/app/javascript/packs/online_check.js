import consumer from "../channels/consumer"


function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

function handleData(data) {
	if (data.type == "online") {
		notification("success", data.info);
	}
	else if(data.type == "offline") {
		notification("error", data.info);
	}
	else {
		$('#notif_banner').html('');
		$('#notif_banner').html(data.info);
		$('#notif_banner').css({'background-color' : data.color, 'text-align' : 'center', 'font-weight' : '1000', 'font-size' : '25px'});
		if (data.type == "duel") {
			$('#notif_banner').off('click');
			$('#notif_banner').click(function(){
				$('#notif_banner').html('');
				$('#notif_banner').off('click');
				window.location='/#show_game/' + data.id;
				});
		}
		else if (data.type == "warTimeNotif") {
			$('#notif_banner').off('click');
			$('#notif_banner').click(function(){
				$('#notif_banner').off('click');
				$('#notif_banner').html('');
				window.location.href = '/#show_war/' + data.id;
				});
		}
		else if (data.type == "warMatchRequest") {
			$('#notif_banner').off('click');
			$('#notif_banner').click(function(){
				$('#notif_banner').html('');
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
						else if(game.status == "multiple_games") {
							notification("error", data.info);
						}
						else {
							notification("success", "Starting game #" + data.id);
							window.location.href = "#show_game/" + data.id.toString();
						}
					}
				);
			})
		}
	}
}

var id = $('#player_data_general').data('id');

var actionCable = consumer.subscriptions.create({ channel: "PresenceChannel", room: id}, {
    connected() {
    },

  	disconnected() {
    },

	received(data) {
		handleData(data);
	}
});

function check_id() {
	if (!id) {
		actionCable.unsubscribe();
		id = $('#player_data_general').data('id');
		actionCable = consumer.subscriptions.create({ channel: "PresenceChannel", room: id}, {
			connected() {
			},
		
			disconnected() {
			},
		
			received(data) {
				handleData(data);
			}
		});
	}
	else {
		clearInterval(interval_id_check);
	}
}

var interval_id_check = setInterval(check_id, 1000);