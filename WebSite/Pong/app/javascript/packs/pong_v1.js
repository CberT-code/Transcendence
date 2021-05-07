var game_id = $('#game_data').data('id');
var user_id = $('#game_data').data('player');
var host_id = $('#game_data').data('host');
var opponent_id = $('#game_data').data('opponent');
var host_name = $('#game_data').data('hostname');
var oppo_name = $('#game_data').data('opponame');
var left = $('#game_data').data('scoreleft');
var right = $('#game_data').data('scoreright');
var status = $('#game_data').data('status');
var keys = [0, 0];
var actionCable;

import consumer from "../channels/consumer"

$(window).resize(resize_game);
if (opponent_id != -1)
	$("#content-game_show #right_PP_show_game").attr("onclick", "window.location='/#show_user/" + opponent_id + "'");
$("#content-game_show #left_PP_show_game").attr("onclick", "window.location='/#show_user/" + host_id + "'");

resize_game();
$.post(
	'/histories/readyCheck/' + game_id,
	{'authenticity_token': $('meta[name=csrf-token]').attr('content') },
	function (data) 
	{
		if (data.status == "error") 
			notification("error", data.info);
		else if (data.status == "timeout" || data.status == "disconnect") {
			notification("error", data.info);
			window.location.href = "#play";
		}
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
	endgame(left > right ? host_id : opponent_id,
			left < right ? host_id : opponent_id, 0,
			right == -1 ? "timeout" : (left > right ? host_name : oppo_name))
}

if (status != "ended") {
	actionCable = consumer.subscriptions.create({ channel: "PongChannel", room: game_id}, {
		connected() {
			if (user_id == host_id || user_id == opponent_id) {
				console.log('CONNECTED '+ game_id);
				document.addEventListener('keydown', keyDown);
				document.addEventListener('keyup', keyUp);
			}
		},

		disconnected() {
			console.log('DISCONNECTED '+ game_id);
				killListeners(actionCable);
			},

		received(data) {
			status = data['status'];
			if (status == "running" ) {
				display(data['left_y'], data['right_y'], data['ball_x'], data['ball_y'], data['score']);
			}
			else if (status == "waiting") {
				$("#content-game_show #game_show_score").html(data.score);
			}
			else if (status == "ready" ) {
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
				killListeners(actionCable);
				actionCable.unsubscribe();
			}
			else if (status == "deleted") {
				killListeners(actionCable);
				actionCable.unsubscribe();
			}
		}
	});
}

function keyUp(event) {
	if (event.key == 'Z' || event.key == 'z' || event.key == 'w' || event.key == 'W' || event.key == "ArrowUp")
		keys[0] = 0;
	else if (event.key == 'S' || event.key == 's' || event.key == "ArrowDown")
		keys[1] = 0;
	sendMove(actionCable);
}

function keyDown(event) {
	if (event.key == 'Z' || event.key == 'z' || event.key == 'w' || event.key == 'W' || event.key == "ArrowUp")
		keys[0] = 1;
	else if (event.key == 'S' || event.key == 's' || event.key == "ArrowDown")
		keys[1] = 1;
	sendMove(actionCable);
}

function killListeners(socket) {
	document.removeEventListener('keyup', keyUp);
	document.removeEventListener('keydown', keyDown);
	socket.send({player: user_id, move: "online"});
}

function foreverAlone() {
	if (status == "waiting") {
		$('#content-game_show #end_game').css('visibility', 'hidden');
		$('#content-game_show #game').css('visibility', 'visible');
		$('#content-game_show #alone').hide();
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
	$('#content-game_show #game').css('visibility', 'hidden');
	$('#content-game_show #end_game').css('visibility', 'visible');
	var msg = "";
	if (w_name == "timeout") {
		msg = "<p class=\"p_end_game\">Enemy forfeited!</p>"
	}
	else if (user_id == winner) {
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
	else {
		msg = "<p class=\"p_end_game\">" + w_name + " Won!</p>";
	}
	$('#content-game_show #end_game').html(msg);
}

function display(left_y, right_y, ball_x, ball_y, score) {
	if ($(document).find('#content-game_show').length != 0) {
		$("#content-game_show #left_player").css({"top": left_y});
		$("#content-game_show #right_player").css({"top": right_y});
		$("#content-game_show #ball").css({"left": ball_x, "top": ball_y});
		$("#content-game_show #game_show_score").html(score);
	}
}

function resize_game() {
	var width = window.innerWidth;
	var height = window.innerHeight;
	if ($('#content-game_show').find("#end_game").length != 0) {
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
	}
	if ($('#content-game_show').find("#wrapper_box").length != 0) {
		if (width < 2.5 * height) {
			document.querySelector("#content-game_show #wrapper_box").style.width = (width * 0.7) + "px";
			document.querySelector("#content-game_show #wrapper_box").style.height = (width * 0.28) + "px";
		}
		else {
			document.querySelector("#content-game_show #wrapper_box").style.width = (height * 1.75) + "px";
			document.querySelector("#content-game_show #wrapper_box").style.height = (height * 0.7) + "px";
		}
	}
}

function notification(typef, textf) {
    var notification = new Noty({ theme: 'mint', type: typef, text: textf });
    notification.setTimeout(4500);
    notification.show();
}