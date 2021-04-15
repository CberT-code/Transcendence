var id = $('#game_data').data('id');
var player_id = $('#game_data').data('player');
var host_id = $('#players').data('host');
var opponent_id = $('#players').data('opponent');
var status = $('#game_data').data('statut');
var right_pp = "";
var keys = [0, 0];
var waiting_id = 0;
var waiting;
var ready = 1;

import consumer from "../channels/consumer"

document.getElementById("alone").addEventListener("click", foreverAlone, false);
document.getElementById("stop").addEventListener("click", stopGame, false);
$(window).resize(resize_game);

resize_game();
if (status == "Looking For Opponent") {
	waiting = setInterval(wait, 120); }
else if (status == "ready" || status == "running") {
	$('#game').css('visibility', 'visible');
	// $.post('/histories/run/' + id); // REMOVE THIS, ONLY FOR DEBUG!!!
}
else if (status == "ended") {
	var left = $('#game_data').data('left');
	var right = $('#game_data').data('right');
	$('#score').html(left + " - " + right);
	ready = 0;
}

if (ready) {
	var actionCable = consumer.subscriptions.create({ channel: "PongChannel", room: id}, {
		connected() {
			if (player_id == host_id || player_id == opponent_id) {
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
				console.log("player : " + player_id);
				console.log("host : " + host_id);
				console.log("opponent : " + opponent_id);
			}
		},

	disconnected() {
			console.log("Disconnected from PongChannel, room " + id + " status " + status);
		},

	received(data) {
		status = data['status'];
		$("#foo").html(data['body'] + " " + " status : " + status);
		if (status == "running" ) {
			display(data['left_y'], data['right_y'], data['ball_x'], data['ball_y'], data['score']);
		}
		else if (status == "ready" ) {
			clearInterval(waiting);
			right_pp = "url(\"" + data['right_pp'] + "\")";
			$("#right_PP").css("background-image", right_pp);
			$('#game').css('visibility', 'visible');
			$.post('/histories/run/' + id);
			console.log("received data from socket: game ready, post sent");
		}
		else if (status == "ended") {
			$('#game').css('visibility', 'hidden');
			endgame(data['winner'], data['loser'], data['elo'], data['w_name']);
			ready = 0;
			actionCable.unsubscribe();
		}
		else if (status == "deleted") {
			ready = 0;
			actionCable.unsubscribe();
		}
		else {
			console.log("Rceived data when it shoudn't have. Status : " + status);
		}
	}
	});
}

function stopGame() {
	clearInterval(waiting);
	$('#game').css('visibility', 'hidden');
	$.post('/histories/stop/' + id);
}

function foreverAlone() {
	if (status != "running") {
		$("#right_PP").css("background-image", "url(\"https://pbs.twimg.com/profile_images/2836953017/11dca622408bf418ba5f88ccff49fce1.jpeg\")");
		$("#left_PP").css("background-image", "url(\"https://pbs.twimg.com/profile_images/2836953017/11dca622408bf418ba5f88ccff49fce1.jpeg\")");
		$('#game').css('visibility', 'visible');
		clearInterval(waiting);
		$.post('/histories/run/' + id);
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
	socket.send({player: player_id, move: move, room: id, status: status});
}

function endgame(winner, loser, elo, w_name) {
	console.log("Game ended, there will be a nice endgame animation, yay");
	$('#end_game').css('visibility', 'visible');
	var msg = "";
	if (player_id == winner) {
		msg = "<p class=\"p_end_game\">You Won !</p>";
		if (elo != "0") {
			msg += "<p> +" + elo + " points!</p>";
		}
	}
	else if (player_id == loser) {
		$('#end_game').css('color', 'red');
		msg = "<p class=\"p_end_game\">You Lost !</p>";
		if (elo != "0") {
			msg += "<p class=\"p_end_game\"> -" + elo + " points!</p>";
		}
	}
	else {
		msg = w_name + " Won !"
	}
	$('#end_game').html(msg);
}

function display(left_y, right_y, ball_x, ball_y, score) {
	$("#left_player").css({"top": left_y});
    $("#right_player").css({"top": right_y});
    $("#ball").css({"left": ball_x, "top": ball_y});
    $("#score").html(score);
}

function wait() {
	if (status == "deleted") {
		clearInterval(waiting);
		return ;
	}
	if (waiting_id == 0) {
		$('#score').html('Waiting for opponent \\');
    }
    if (waiting_id == 1) {
		$('#score').html('Waiting for opponent |');
    }
    if (waiting_id == 2) {
		$('#score').html('Waiting for opponent /');
    }
    if (waiting_id == 3) {
		$('#score').html('Waiting for opponent -');
    }
	waiting_id = (waiting_id + 1) % 4;
}

function resize_game() {
	var width = window.innerWidth;
	var height = window.innerHeight;
	if (width < 550) {
		$('#end_game').css('font-size', '2vh');
	}
	else if (width < 900) {
		$('#end_game').css('font-size', '5vh');
	}
	else if (width < 1300) {
		$('#end_game').css('font-size', '8vh');
	}
	else {
		$('#end_game').css('font-size', '11vh');
	}
	if (width < 2.5 * height) {
		document.getElementById("wrapper_box").style.width = (width * 0.7) + "px";
		document.getElementById("wrapper_box").style.height = (width * 0.28) + "px";
	}
	else {
		document.getElementById("wrapper_box").style.width = (height * 1.75) + "px";
		document.getElementById("wrapper_box").style.height = (height * 0.7) + "px";
	}
}