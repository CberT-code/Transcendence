var id = $('#game_data').data('id');
var player_id = $('#game_data').data('player');
var status = $('#game_data').data('statut');
var right_pp = "";
var keys = [0, 0];

import consumer from "../channels/consumer"

function sendMove(socket) {
	var move;
	if (keys[0] == keys[1])
		move = "static";
	else if (keys[0] == 1)
		move = "down";
	else
		move = "up";
	socket.send({player: player_id, move: move, room: id});
}

var tmp = consumer.subscriptions.create({ channel: "PongChannel", room: id}, {
    connected() {
		console.log("status : " + status);
		$.post('/histories/wait/' + id);
		$(document).keydown(function(event) {
			if (event.key == 'q')
				keys[0] = 1;
			else if (event.key == 'a')
				keys[1] = 1;
			else
				console.log("You pressed |" + event.key + "|");
			sendMove(tmp);
		});
		$(document).keyup(function(event) {
			if (event.key == 'q')
				keys[0] = 0;
			else if (event.key == 'a')
				keys[1] = 0;
			sendMove(tmp);
		});
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
    else if (status == "Looking For Opponent" ) {
        waiting(parseInt(data['frame'], 10));
    }
    else if (status == "ready" ) {
		right_pp = "url(\"" +data['right_pp'] + "\")";
		$("#right_PP").css("background-image", right_pp);
        $('#game').css('visibility', 'visible');
		$.post('/histories/run/' + id);
	}
	else if (status == "ended") {
		$('#game').css('visibility', 'hidden');
		// end of game action/animation
	}
	else {
		console.log("Status : " + status);
	}
}
});

function waiting(waiting_id) {
	if (waiting_id % 4 == 0) {
		$('#score').html('Waiting for opponent \\');
    }
    if (waiting_id % 4 == 1) {
		$('#score').html('Waiting for opponent |');
    }
    if (waiting_id % 4 == 2) {
		$('#score').html('Waiting for opponent /');
    }
    if (waiting_id % 4 == 3) {
		$('#score').html('Waiting for opponent -');
    }
}

function display(left_y, right_y, ball_x, ball_y, score) {
	$("#left_player").css("top", left_y);
    $("#right_player").css("top", right_y);
    $("#ball").css("left", ball_x);
    $("#ball").css("top", ball_y);
    $("#score").html(score);
}