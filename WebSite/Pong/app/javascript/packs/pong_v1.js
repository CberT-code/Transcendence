var id = $('#game_data').data('id');
var player_id = $('#game_data').data('player');
var status = $('#game_data').data('statut');
var right_pp = "";
var keys = [0, 0];
var waiting_id = 0;
var waiting;

import consumer from "../channels/consumer"

document.getElementById("alone").addEventListener("click", foreverAlone, false);

function foreverAlone() {
	console.log(status);
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

var actionCable = consumer.subscriptions.create({ channel: "PongChannel", room: id}, {
    connected() {
		// console.log("status : " + status);
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
    },

  disconnected() {
	  	actionCable.send({player: player_id, room: id, status: "gone"});
		console.log("Disconnected from PongChannel, room " + id + " status " + status);
    },

  received(data) {
	status = data['status'];
	$("#foo").html(data['body'] + " " + " status : " + status);
	if (status == "running" ) {
		display(data['left_y'], data['right_y'], data['ball_x'], data['ball_y'], data['score']);
	}
    // else if (status == "Looking For Opponent" ) {
    //     waiting(parseInt(data['frame'], 10));
    // }
    else if (status == "ready" ) {
		clearInterval(waiting);
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

function display(left_y, right_y, ball_x, ball_y, score) {
	$("#left_player").css("top", left_y);
    $("#right_player").css("top", right_y);
    $("#ball").css("left", ball_x);
    $("#ball").css("top", ball_y);
    $("#score").html(score);
}

function wait() {
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

console.log(status);
if (status == "Looking For Opponent") {
	waiting = setInterval(wait, 90); }
else if (status == "ready") {
	$('#game').css('visibility', 'visible');
	// $.post('/histories/run/' + id); // REMOVE THIS, ONLY FOR DEBUG!!!
}
else if (status == "ended") {
	var left = $('#game_data').data('left');
	var right = $('#game_data').data('right');
	$('#score').html(left + " - " + right);
}