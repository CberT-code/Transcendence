var game_id = $('#game_data').data('id');
var user_id = $('#game_data').data('player');
var host_id = $('#game_data').data('host');
var opponent_id = $('#game_data').data('opponent');
var status = $('#game_data').data('status');
var keys = [0, 0];

import consumer from "../channels/consumer"

$(window).resize(resize_game);

resize_game();
$.post(
	'/histories/readyCheck/' + game_id,
	{'authenticity_token': $('meta[name=csrf-token]').attr('content') },
	function (data) 
	{
		if (data.status == "error")
			notification("error", data.info);
	},
);
if ($('#content-game_show').find("#alone").length != 0) {
	document.querySelector("#content-game_show #alone").addEventListener("click", foreverAlone, false);
}
else if (status == "ready" || status == "running") {
	$('#content-game_show #game').css('visibility', 'visible');
	$('#content-game_show #alone').hide();
}
else if (status == "ended") {
	$('#content-game_show #game').css('visibility', 'hidden');
	$('#content-game_show #end_game').css('visibility', 'visible');
	$('#content-game_show #alone').hide();
}

if (status != "ended") {
	var actionCable = consumer.subscriptions.create({ channel: "PongChannel", room: game_id}, {
		connected() {
			if (user_id == host_id || user_id == opponent_id) {
				$(document).keydown(function(event) {
					if (event.key == 'q' || event.key == 'z')
						keys[0] = 1;
					else if (event.key == 'a' || event.key == 's')
						keys[1] = 1;
					else
						console.log("You pressed |" + event.key + "|");
					sendMove(actionCable);
				});
				$(document).keyup(function(event) {
					if (event.key == 'q' || event.key == 'z')
						keys[0] = 0;
					else if (event.key == 'a' || event.key == 's')
						keys[1] = 0;
					sendMove(actionCable);
				});
			}
			else {
				console.log("Streaming live game " + game_id);
				console.log("host : " + host_id);
				console.log("opponent : " + opponent_id);
			}
		},

		disconnected() {
				console.log("Disconnected from PongChannel, room " + game_id + " status " + status);
			},

		received(data) {
			status = data['status'];
			if (status == "running" ) {
				display(data['left_y'], data['right_y'], data['ball_x'], data['ball_y'], data['score']);
			}
			else if (status == "waiting") {
				$("#content-game_show #score").html(data.score);
			}
			else if (status == "ready" ) {
				console.log("game is ready!");
				var right_pp = "url(\"" + data['right_pp'] + "\")";
				var left_pp = "url(\"" + data['left_pp'] + "\")";
				$("#content-game_show #right_PP_show_game").css("background-image", right_pp + ", url(\'https://cdn.intra.42.fr/users/medium_default.png\')");
				$("#content-game_show #left_PP_show_game").css("background-image", left_pp + ", url(\'https://cdn.intra.42.fr/users/medium_default.png\')");
				$('#content-game_show #game').css('visibility', 'visible');
				$('#content-game_show #alone').hide();
			}
			else if (status == "ended") {
				$('#content-game_show #game').css('visibility', 'hidden');
				$('#content-game_show #alone').hide();
				endgame(data['winner'], data['loser'], data['elo'], data['w_name']);
				actionCable.unsubscribe();
			}
			else if (status == "deleted") {
				actionCable.unsubscribe();
			}
			else {
				console.log("Rceived data when it shoudn't have. Status : " + status);
			}
		}
	});
}

function foreverAlone() {
	console.log(status);
	if (status == "waiting") {
		$('#content-game_show #end_game').css('visibility', 'hidden');
		$('#content-game_show #game').css('visibility', 'visible');
		$('#content-game_show #alone').hide();
		console.log("sending alone request");
		$.post(
			'/histories/forever_alone/' + game_id,
			{'authenticity_token': $('meta[name=csrf-token]').attr('content') },
			function (data) 
			{
				if (data.status == "error")
					notification("error", data.info);
			},
		);
	}
}

function sendMove(socket) {
	var move;
	if (keys[0] == keys[1])
		move = "static";
	else if (keys[0] == 1)
		move = "down";
	else
		move = "up";
	socket.send({player: user_id, move: move, room: game_id, status: status});
}

function endgame(winner, loser, elo, w_name) {
	console.log("Game ended, there will be a nice endgame animation, yay");
	$('#content-game_show #game').css('visibility', 'hidden');
	$('#content-game_show #end_game').css('visibility', 'visible');
	var msg = "";
	if (user_id == winner) {
		msg = "<p class=\"p_end_game\">You Won !</p>";
		if (elo != "0") {
			msg += "<p> +" + elo + " points!</p>";
		}
	}
	else if (user_id == loser) {
		$('#content-game_show #end_game').css('color', 'red');
		msg = "<p class=\"p_end_game\">You Lost !</p>";
		if (elo != "0") {
			msg += "<p class=\"p_end_game\"> -" + elo + " points!</p>";
		}
	}
	else if (w_name == "Timeout") {
		msg = "<p class=\"p_end_game\">Enemy forfeited!</p>"
	}
	else {
		msg = "<p class=\"p_end_game\">" + w_name + " Won!</p>";
	}
	$('#content-game_show #end_game').html(msg);
}

function display(left_y, right_y, ball_x, ball_y, score) {
	$("#content-game_show #left_player").css({"top": left_y});
    $("#content-game_show #right_player").css({"top": right_y});
    $("#content-game_show #ball").css({"left": ball_x, "top": ball_y});
    $("#content-game_show #score").html(score);
}

function resize_game() {
	var width = window.innerWidth;
	var height = window.innerHeight;
	if (width < 550) {
		$('#content-game_show #end_game').css('font-size', '2vh');
	}
	else if (width < 900) {
		$('#content-game_show #end_game').css('font-size', '5vh');
	}
	else if (width < 1300) {
		$('#content-game_show #end_game').css('font-size', '8vh');
	}
	else {
		$('#content-game_show #end_game').css('font-size', '11vh');
	}
	if (width < 2.5 * height) {
		document.querySelector("#content-game_show #wrapper_box").style.width = (width * 0.7) + "px";
		document.querySelector("#content-game_show #wrapper_box").style.height = (width * 0.28) + "px";
	}
	else {
		document.querySelector("#content-game_show #wrapper_box").style.width = (height * 1.75) + "px";
		document.querySelector("#content-game_show #wrapper_box").style.height = (height * 0.7) + "px";
	}
}

function notification(typef, textf) {
    var notification = new Noty({ theme: 'mint', type: typef, text: textf });
    notification.setTimeout(4500);
    notification.show();
}