document.getElementById("spectate_title").addEventListener("click", History_to_spectate, false);
document.getElementById("history_title").addEventListener("click", Spectate_to_History, false);
$(window).resize(check_game_size);

check_game_size();

function History_to_spectate() {
	var width = window.innerWidth;
	if (width < 1200) {
		width = Math.ceil((width - 412) / 2).toString() + "px";
		$('.history').hide();
		$('.spectate').show()
		$('.spectate').css({'right' : width, 'background-color' : 'cadetblue'});
		$('.title').css('width', '200px');
		$('#spectate_title').css({'z-index' : '1',});
		$('#history_title').css({'z-index' : '0', 'background-color' : 'grey'});
		$('#history_title').show();
	}
}
function Spectate_to_History() {
	var width = window.innerWidth;
	if (width < 1200) {
		width = (Math.ceil((width - 412) / 2)).toString() + "px";
		$('.history').show();
		$('.spectate').hide();
		$('.history').css({'left' : width, 'background-color' : 'cadetblue'});
		$('.title').css('width', '200px');
		$('#spectate_title').css({'z-index' : '0', 'background-color' : 'grey', 'right' : width});
		$('#history_title').css('z-index', '1');
		$('#spectate_title').show();
	}
}

function check_game_size() {
	var width = window.innerWidth;
	if (width < 1200) {
		Spectate_to_History();
	}
	else if (width < 1920) {
		var tmp = ((width / 48) - 15).toFixed(1).toString() + "%";
		$('.spectate').show()
		$('.history').show();
		$('.history').css({'left' : tmp, 'background-color' : 'grey'});
		$('.spectate').css({'right' : tmp, 'background-color' : 'grey'});
		$('.title').css('width', '400px');
	}
	// else {
	// 	$('.history').css({'left' : '25%', 'right' : '', 'margin' : ''})
	// 	$('.spectate').css({'left' : '', 'right' : '25%', 'margin' : ''});
	// }
}