var ball = document.getElementById("ball");
var waiting_id = 0;
var id = $('#game_data').data('id');
var status = $('#game_data').data('statut');
var right_pp = "";
var left_h = 150;
var right_h = 150;
var keys = [0, 0];
var ball = [250, 200]; // Ball (x, y)
var score = [0, 0];
var inter = 500;


import consumer from "../channels/consumer"

var tmp = consumer.subscriptions.create({ channel: "PongChannel", room: id}, {
    connected() {
		if (status != 42) {
			console.log("connected to PongChannel room " + id + " status : " + status);
			$.post('/histories/wait/' + id, "",
				function (data) {
					$('#dev').html(JSON.stringify(data));
					status = data['status'];
					right_pp = "url(" + data['right_pp'] + ")";
				}
			);
			$(document).keydown(function(event) {
				if (event.key == 'a' && !keys[0]) {
					tmp.send({player: "up"});
					keys[0] = 1;
					console.log("user pressed " + event.key);
				}
				else if (event.key == 'q' && !keys[1]) {
					tmp.send({player: "down"});
					keys[1] = 1;
					console.log("user pressed " + event.key);
				}
			} );
			$(document).keyup(function(event) {
				if (event.key == 'a' && keys[0]) {
					tmp.send({player: "up"});
					keys[0] = 0;
					console.log("user released " + event.key);
				}
				else if (event.key == 'q' && keys[1]) {
					tmp.send({player: "down"});
					keys[1] = 0;
					console.log("user released " + event.key);
				}
			}
			);
		}
    },

  disconnected() {
		status = 42;
		console.log("Disconnected from PongChannel, room " + id + " status " + status);
    },

  received(data) {
    $("#foo").html(data['body'] + " " + data['test_var'] + " fps : " + data['fps'] + " status : " + data['status'] + " user : " + data['user']);
    if (status == "0" ) {
        // waiting(data);
    }
    else if (status == "1" ) {

    }
    else if (status == "2" ) {

    }
  }
});


function display() {
    $("#left_player").css("top", left_h);
    $("#right_player").css("top", right_h);
    $("#ball").css("left", ball[0]);
    $("#ball").css("top", ball[1]);
    $("#score").html(score[0] + " - " + score[1]);
}

function game_loop() {
    $.post('/histories/run/' + id, 
                {   down: keys[0],
                    up: keys[1]
                },
            function (data) {
                $('#dev').html(JSON.stringify(data));
                left_h = data['left'];
                right_h = data['right'];
                status = data['status'];
                id = data['id'];
                ball[0] = data['ball_x'];
                ball[1] = data['ball_y'];
                score[0] = data['host'];
                score[1] = data['oppo'];
            },
            'json');
    display();
    if (status != "2") {
        console.log("Exiting game loop" + status)
        $('#game').css('visibility', 'hidden');
        clearInterval(run);
    }
}

function waiting() {
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
    waiting_id = (waiting_id + 1) % (32);
}

function check_wait_status() {
    $.post('/histories/wait/' + id, "",
            function (data) {
                $('#dev').html(JSON.stringify(data));
                status = data['status'];
                right_pp = "url(" + data['right_pp'] + ")";
            } );
    if (status == 1) {
        $("#right_PP").css("background-image", right_pp);
        console.log(rght_pp);
    }
}

function master() {
    id = $('#game_data').data('id');
    if (status == "2") {
        $('#game').css('visibility', 'visible');

        inter = 25;
        clearInterval(run);
        run = setInterval(game_loop, inter);
        return ;
    }
    else if (status == "1") {
        $("#right_PP").css("background-image", right_pp);
        $.post('/histories/wait/' + id, { ready: "ok" },
            function(data) {
                status = data['status'];
            });
    }
    else if (status == "0") {
        if (waiting_id == 0) {
            $("#right_PP").css("background-image", "url(https://cdn.intra.42.fr/users/norminet.jpg)");
            check_wait_status();
        }
        waiting();
    }
    else {
        console.log(status + " ending run");
        clearInterval(run);
    }
}
   
// var run = setInterval(master, inter);