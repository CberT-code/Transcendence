// var left = document.getElementById("left_player");
// var right = document.getElementById("right_player");
var ball = document.getElementById("ball");
var waiting_id = 0;
var id = -1;
var status = $('#game_data').data('statut');
var right_pp = "";
var left_h = 150;
var right_h = 150;
var keys = [0, 0];
var ball = [250, 200]; // Ball (x, y)
// var width = parseInt(getComputedStyle(document.documentElement)
// .getPropertyValue('--game_width'));
// var height = parseInt(getComputedStyle(document.documentElement)
// .getPropertyValue('--game_height'));
// var p_height = parseInt(getComputedStyle(document.documentElement)
// .getPropertyValue('--player_height'));
// var p_width = parseInt(getComputedStyle(document.documentElement)
// .getPropertyValue('--player_width'));
// var ball_w = parseInt(getComputedStyle(document.documentElement)
// .getPropertyValue('--ball_width'));
// var ball_pos = [(width - ball_w) / 2, height / 2];
var score = [0, 0];
// var direction_x = 1;
// var y_coef = Math.random() * 4 - 2;
var inter = 100;
// var step = (width - p_width * 2) * inter / 5000;
// var ball_max_x = width - p_width - ball_w;
// var ball_min_x = p_width;
// var end = 1;
// let pause_status = 0;

document.addEventListener('keypress', logKey);
document.addEventListener('keyup', releaseKey);
// document.getElementById("pause").addEventListener("click", ft_pause, false);

function logKey(e) {
    if (e.key == 'a' || e.key == 'ArrowUp') {
        keys[0] = 1;
    }
    else if (e.key == 'q' || e.key == 'ArrowDown') {
        keys[1] = 1;
    }
}

function releaseKey(e) {
    if (e.key == 'a' || e.key == 'ArrowUp') {
        keys[0] = 0;
    }
    else if (e.key == 'q' || e.key == 'ArrowDown') {
        keys[1] = 0;
    }
    else
        console.log("Invalid input : " + e.key);
}

// function height_limit() {
//     if (left_h < 0)
//         left_h = 0;
//     if (right_h < 0)
//         right_h = 0;
//     if (left_h > height - p_height)
//         left_h = height - p_height;
//     if (right_h > height - p_height)
//         right_h = height - p_height;
// }

// function ball_move_x() {
//     if (direction_x) {
//         if (ball_pos[0] > ball_min_x)
//             ball_pos[0] -= step;
//         else {
//             check_end(ball_pos[1], left_h, direction_x);
//             document.getElementById("score").innerHTML = score[0] + " - " + score[1];
//             if (keys[0])
//                 y_coef += 0.3;
//             if (keys[1])
//                 y_coef -= 0.3;
//             direction_x = 0;
//         }
//     }
//     else {
//         if (ball_pos[0] < ball_max_x)
//             ball_pos[0] += step;
//         else {
//             check_end(ball_pos[1], right_h, direction_x);
//             document.getElementById("score").innerHTML = score[0] + " - " + score[1];
//             direction_x = 1;
//             if (keys[2])
//                 y_coef += 0.3;
//             if (keys[3])
//                 y_coef -= 0.3;
//         }
//     }
// }

// function ball_move_y() {
//    ball_pos[1] += y_coef * step;
//    if (ball_pos[1] <= 0 || ball_pos[1] + ball_w >= height) {
//        y_coef *= -1;
//    }
// }

// function display() {
//     ball.style.left = ball_pos[0] + "px";
//     ball.style.top = ball_pos[1] + "px";
//     left.style.top = left_h + "px";
//     right.style.top = right_h + "px";
// }

// function testing_ajax() {
//     $.post('/pong/loop', 
//             {   UD: keys[0], // left Up
//                 UU: keys[1], // left Down
//                 height: height - p_height//game height
//             },
//         function (data) {
//             $('#dev').html(JSON.stringify(data));
//             left_h = data['left'];
//             right_h = dat['right'];
//         },
//         'json');
//   }

function display() {
    document.getElementById("score").innerHTML = score[0] + " - " + score[1];
    $("#left_player").css("top", left_h);
    $("#right_player").css("top", right_h);
    $("#ball").css("left", ball[0]);
    $("#ball").css("top", ball[1]);
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
            },
            'json');
    display();
    if (status != 1)
        clearInterval(run);
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
    // console.log("wait id : " + waiting_id);
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
    }
}

function master() {
    // console.log("Status : " + status);
    id = $('#game_data').data('id');
    if (status == "1") {
        $('#game').css('visibility', 'visible');

        inter = 33;
        clearInterval(run);
        run = setInterval(game_loop, inter);
        return ;
    }
    else if (status == "0") {
        if (waiting_id == 0) {
            $("#right_PP").css("background-image", "url(https://cdn.intra.42.fr/users/norminet.jpg)");
            check_wait_status();
        }
        waiting();
    }
    else {
        clearInterval(run);
    }
    // if ($('#left_data').data('source').status == 'LFO') {
    //     $('#score').html('Waiting for right ... ');
    //     return ;
    // }
    // else
        // $('#game').css('visibility', 'visible');
    // if (pause_status)
    //     return ;
    // testing_ajax();
    // if (end) {
    //     height_limit();
    //     ball_move_x();
    //     ball_move_y();
    //     display();
    // }
    // else {
    //     display();
    //     sleep(1000);
    //     y_coef = Math.random() * 4 - 2;
    //     end = 1;
    //     ball_pos[0] = (width - ball_w) / 2;
    //     ball_pos[1] = height / 2;
    //     display();
    // }
    // step *= 1.0005;
}

// function check_end(ball_y, p_y, dir) {
//     if (ball_y > p_y + p_height || p_y > ball_y + ball_w) {
//         var sens = -(dir * 2 - 1);
//         end = 0;
//         ball_pos[0] += (sens * step);
//         score[dir] += 1;
//         return 1;
//     }
//     return 0;
// }

// var ready = 0;
// while (!ready)
// {
//     $.post('/pong/setup', 
//             {   // name: value //send
//                 status: 'are_you_ok_ani';
//             },
//         function (data) {
//             //return 
//             $('#dev').html(JSON.stringify(data));
//         },
//         'json'); //type
//     sleep(5000);
// }
// $("#left_PP").css("background-image", data['Left_pp']);
// $("#right_PP").css("background-image", data['Right_pp']);

var run = setInterval(master, inter);