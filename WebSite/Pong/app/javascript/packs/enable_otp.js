require("packs/qrcode.js")
document.querySelector("#content-account #enable_otp").addEventListener("click", enable_otp, false);
var id = $('#player_data').data('id');


function enable_otp() {
	$.post("/users/enable_otp/" + id.toString(), function(data) {
		if (data.status == "error") {
			console.log(data.info);
		}
		else if (data.status == "ok") {
			$('#qrcode').html("");
			$('#qrcode').qrcode(data.info);
			$('#qrcode').css({'margin-left' : '200px'});
		}
	});
}