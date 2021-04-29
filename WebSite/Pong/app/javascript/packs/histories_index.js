document.querySelector("#content-history #spectate_title").addEventListener("click", wrapper_History_to_spectate, false);
document.querySelector("#content-history #history_title").addEventListener("click", wrapper_Spectate_to_History, false);
$(window).resize(check_game_size);

var toggle = 0;
check_game_size();

function wrapper_History_to_spectate() {
	History_to_spectate()
	toggle = 0;
}

function wrapper_Spectate_to_History() {
	toggle = 1;
	Spectate_to_History()
}

function History_to_spectate() {
	var width = window.innerWidth;
	if (width < 1200) {
		var left = Math.ceil((width - 412) / 2);
		var right = !(width % 2) ? left : left -1;
		left = left.toString() + "px"
		right = right.toString() + "px"
		$('.history').hide();
		$('.spectate').show()
		$('.spectate').css({'right' : right});
		$('.title').css('width', '200px');
		$('#spectate_title').css({'z-index' : '2','background-color' : 'cadetblue', 'right' : right});
		$('#history_title').css({'z-index' : '1', 'background-color' : 'grey', 'left' : left});
		$('#history_title').show();
	}
}
function Spectate_to_History() {
	var width = window.innerWidth;
	if (width < 1200) {
		var left = Math.ceil((width - 412) / 2);
		var right = !(width % 2) ? left : left -1;
		left = left.toString() + "px"
		right = right.toString() + "px"
		$('.history').show();
		$('.spectate').hide();
		$('.history').css({'left' : left});
		$('.title').css('width', '200px');
		$('#spectate_title').css({'z-index' : '1', 'background-color' : 'grey', 'right' : right});
		$('#history_title').css({'z-index' : '2', 'background-color' : 'cadetblue', 'left' : left});
		$('#spectate_title').show();
	}
}

function check_game_size() {
	var width = window.innerWidth;
	var height = window.innerHeight;
	var tmp = ((width / 48) - 15).toFixed(1).toString() + "%";
	place_buttons(width, tmp);
	if (width < 1200) {
		if (toggle) {
			Spectate_to_History();
		}
		else {
			History_to_spectate();
		}
	}
	else if (width < 1920) {
		$('.spectate').show()
		$('.history').show();
		$('.history').css({'left' : tmp});
		$('.spectate').css({'right' : tmp});
		$('.title').css({'width' : '400px', 'background-color' : 'cadetblue'});
	}
	// else {
	// 	$('.history').css({'left' : '25%', 'right' : '', 'margin' : ''})
	// 	$('.spectate').css({'left' : '', 'right' : '25%', 'margin' : ''});
	// }
}

function place_buttons(width, tmp){
	if ($('#continue_trigger').html() == "CONTINUE") {
		console.log("continue game: " + $('#continue_trigger').data('id'));
		$('#continue').css({'left' : ((width / 2) - 150).toString() + "px", 'top' : '80px'});
		$('.new_game').hide();
		$('#continue').show();
	}
	else {
		$('.new_game').show();
		$('#continue').hide();
	}
}