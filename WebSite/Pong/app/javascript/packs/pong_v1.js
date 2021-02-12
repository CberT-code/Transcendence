var user = document.getElementById("user");
var oppo = document.getElementById("opponent");
var ball = document.getElementById("ball");
var user_h = 0;
var oppo_h = 0;
var flags = [0, 0, 0, 0];
var width = parseInt(getComputedStyle(document.documentElement)
.getPropertyValue('--game_width'));
var height = parseInt(getComputedStyle(document.documentElement)
.getPropertyValue('--game_height'));
var p_height = parseInt(getComputedStyle(document.documentElement)
.getPropertyValue('--player_height'));
var p_width = parseInt(getComputedStyle(document.documentElement)
.getPropertyValue('--player_width'));
var ball_w = parseInt(getComputedStyle(document.documentElement)
.getPropertyValue('--ball_width'));
var ball_pos = [(width - ball_w) / 2, height / 2];
var phase = parseInt(getComputedStyle(document.documentElement)
.getPropertyValue('--phase'));
var score = [0, 0];
var direction_x = 1;
var y_coef = Math.random() * 4 - 2;
var inter = 33;
var step = (width - p_width * 2) * inter / phase;
var ball_max_x = width - p_width - ball_w;
var ball_min_x = p_width;
var end = 1;
let pause_status = 0;

document.addEventListener('keypress', logKey);
document.addEventListener('keyup', releaseKey);
document.getElementById("pause").addEventListener ("click", ft_pause, false);

function logKey(e) {
    if (e.key == 'q') {
        flags[0] = 1;
    }
    else if (e.key == 'a') {
        flags[1] = 1;
    }
    else if (e.key == 'o') {
        flags[2] = 1;
    }
    else if (e.key == 'l') {
        flags[3] = 1;
    }
}
function releaseKey(e) {
    if (e.key == 'q') {
        flags[0] = 0;
    }
    else if (e.key == 'a') {
        flags[1] = 0;
    }
    else if (e.key == 'o') {
        flags[2] = 0;
    }
    else if (e.key == 'l') {
        flags[3] = 0;
    }
    else if (e.key == 't') {
        pause_status = (pause_status + 1) % 2;
    }
}

function player_move() {
    if (flags[0] == 1) {
        user_h -= 10;
    }
    if (flags[1] == 1) {
        user_h += 10;
    }
    if (flags[2] == 1) {
        oppo_h -= 10;
    }
    if (flags[3] == 1) {
        oppo_h += 10;
    }
}

function height_limit() {
    if (user_h < 0)
        user_h = 0;
    if (oppo_h < 0)
        oppo_h = 0;
    if (user_h > height - p_height)
        user_h = height - p_height;
    if (oppo_h > height - p_height)
        oppo_h = height - p_height;
}

function ball_move_x() {
    if (direction_x) {
        if (ball_pos[0] > ball_min_x)
            ball_pos[0] -= step;
        else {
            check_end(ball_pos[1], user_h, direction_x);
            document.getElementById("score").innerHTML = score[0] + " - " + score[1];
            if (flags[0])
                y_coef += 0.3;
            if (flags[1])
                y_coef -= 0.3;
            direction_x = 0;
        }
    }
    else {
        if (ball_pos[0] < ball_max_x)
            ball_pos[0] += step;
        else {
            check_end(ball_pos[1], oppo_h, direction_x);
            document.getElementById("score").innerHTML = score[0] + " - " + score[1];
            direction_x = 1;
            if (flags[2])
                y_coef += 0.3;
            if (flags[3])
                y_coef -= 0.3;
        }
    }
}

function ball_move_y() {
   ball_pos[1] += y_coef * step;
   if (ball_pos[1] <= 0 || ball_pos[1] + ball_w >= height) {
       y_coef *= -1;
   }
}

function display() {
    ball.style.left = ball_pos[0] + "px";
    ball.style.top = ball_pos[1] + "px";
    user.style.top = user_h + "px";
    oppo.style.top = oppo_h + "px";
}

function update_pos(obj) {
    user_h = obj.pos_u;
    oppo_h = obj.pos_o;
    status = obj.status;
}

function testing_ajax() {
    $.post('/pong', 
            {   UD: flags[0], // User Up
                UU: flags[1], // User Down
                OD: flags[2], // Opponent Up
                OU: flags[3], // Opponent Down
                pos_u: user_h,
                pos_o: oppo_h,
                ball_x: ball_pos[0],
                ball_y: ball_pos[1],
                status: end
            },
        function (data) {
            $('#dev').html(JSON.parse(data));
            console.log(data);
        },
        'json');
    // var xhttp = new XMLHttpRequest();
    // let pos = [user_h, oppo_h, ball_pos[0], ball_pos[1], end ];
    // xhttp.onreadystatechange = function() {
    //   if (this.readyState == 4 && this.status == 200) {
    //    document.getElementById("demo").innerHTML = this.responseText;
    //    update_pos(JSON.parse(this.responseText));
    //   }
    // };
    // xhttp.open("POST", "/pong", true);
    // xhttp.send(JSON.stringify(
    //     {   'UD': flags[0], // User Up
    //         'UU': flags[1], // User Down
    //         'OD': flags[2], // Opponent Up
    //         'OU': flags[3], // Opponent Down
    //         'pos_u': user_h,
    //         'pos_o': oppo_h,
    //         'ball_x': ball_pos[0],
    //         'ball_y': ball_pos[1],
    //         'status': end
    //     }
    //     ));
  }



function move() {
    if (pause_status)
        return ;
    testing_ajax();
    if (end) {
        // player_move();
        height_limit();
        ball_move_x();
        ball_move_y();
        display();
    }
    else {
        display();
        sleep(1000);
        y_coef = Math.random() * 4 - 2;
        end = 1;
        ball_pos[0] = (width - ball_w) / 2;
        ball_pos[1] = height / 2;
        display();
    }
    step *= 1.001;
}

function sleep(milliseconds) {
    const date = Date.now();
    let currentDate = null;
    do {
      currentDate = Date.now();
    } while (currentDate - date < milliseconds);
}

function check_end(ball_y, p_y, dir) {
    if (ball_y > p_y + p_height || p_y > ball_y + ball_w) {
        var sens = -(dir * 2 - 1);
        end = 0;
        ball_pos[0] += (sens * step);
        score[dir] += 1;
        return 1;
    }
    return 0;
}


function ft_pause() {
    if (pause_status)
        pause_status = 0;
    else
        pause_status = 1;
}

setInterval(move, inter);