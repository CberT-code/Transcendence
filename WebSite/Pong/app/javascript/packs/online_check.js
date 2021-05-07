import consumer from "../channels/consumer"

var id = $('#player_data_general').data('id');
var interval_kill_notif;
var interval_id_check = setInterval(check_id, 1000);
var online_check = consumer.subscriptions.create({ channel: "PresenceChannel", room: id}, {
	connected() {
		console.log("Connectetd " + id);
	},

	  disconnected() {
		console.log("DISConnectetd " + id);
	},

	received(data) {
		handleData(data);
	}
});

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
		$('#notif_banner').css({'display' : 'block'});
		console.log("show banner");
		console.log(data);
		$('#notif_banner').css({'background-color' : data.color, 'text-align' : 'center', 'font-weight' : '1000', 'font-size' : '25px'});
		if (data.type == "duel") {
			console.log(data.info);
			$('#notif_banner').off('click');
			$('#notif_banner').click(function(){
				$('#notif_banner').html('');
				$('#notif_banner').off('click');
				window.location='/#show_game/' + data.id;
			});
			interval_kill_notif = setInterval(kill_notif, 15000);
		}
		else if (data.type == "warTimeNotif") {
			$('#notif_banner').off('click');
			$('#notif_banner').click(function(){
				$('#notif_banner').off('click');
				$('#notif_banner').html('');
				window.location.href = '/#show_war/' + data.war_id;
			});
			interval_kill_notif = setInterval(kill_notif, 15000);
		}
		else if (data.type == "warMatchRequest") {
			$('#notif_banner').off('click');
			$('#notif_banner').click(function(){
				$('#notif_banner').html('');
				$.post(
					'/histories/start_game',
					{
						'authenticity_token': $('meta[name=csrf-token]').attr('content'),
						"tournament_id": data.tournament_id,
						"ranked": true, "war_match": true,
						"war_id": data.war_id,
						"war_match": true,
					},
					function (game) 
					{
						if (game.status == "error")
							notification("error", game.info);
						else {
							notification("success", "Starting game #" + game.id);
							window.location.href = "#show_game/" + game.id;
						}
					}
				);
			})
			interval_kill_notif = setInterval(kill_notif, 20000);
		}
	}
}

function check_id() {
	if (!id) {
		online_check.unsubscribe();
		id = $('#player_data_general').data('id');
		online_check = consumer.subscriptions.create({ channel: "PresenceChannel", room: id}, {
			connected() {
				console.log("Connectetd " + id);
			},
		
			disconnected() {
				console.log("DISConnectetd " + id);
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

function kill_notif() {
	$('#notif_banner').off('click');
	$('#notif_banner').html('');
	$('#notif_banner').css({'display' : 'none'});
	console.log("kill banner");
	clearInterval(interval_kill_notif);
}
