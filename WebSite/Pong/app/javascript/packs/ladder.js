$(window).resize(check_game_size);
check_game_size();

function check_game_size() {
	var width = window.innerWidth;
	var height = window.innerHeight;

	$('#content-ladder #wrapper').css({'height': (height - 70).toString() + "px",
			'left' : (width / 2 - 200).toString() + "px"});
}