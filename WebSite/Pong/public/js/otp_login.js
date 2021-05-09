function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

document.querySelector("#send_otp").addEventListener("click", send_otp, false);

function send_otp() {
	$.post("/otp_check", {"otp": $("#otp_login_otp").val(), 'authenticity_token': $('meta[name=csrf-token]').attr('content')}, function(data) {
		if (data.status == "error") {
			notification("error", data.info);
		}
		else {
			notification("success", data.info);
			$.get("/").then(function(data){
				$("main").html("<div id='content-user'>" + ($(data).find("#content-user").html()) + "</div>");
				});
		}
	})
}
