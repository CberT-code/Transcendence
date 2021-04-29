function notification(typef, textf) {
	var notification = new Noty({ theme: 'mint', type: typef, text: textf });
	notification.setTimeout(4500);
	notification.show();
}

document.querySelector("#send_otp").addEventListener("click", send_otp, false);

function send_otp() {
	$.post("/otp_check", {"otp": $("#otp_login_otp").val(), 'authenticity_token': $('meta[name=csrf-token]').attr('content')}, function(data) {
		if (data.status == "error") {
			console.log(data.info);
			notification("error", data.info);
		}
		else {
			notification("success", data.info);
			// window.location.href = "/#";
			$.get("/").then(function(data){
				$("main").html("<div id='content-home'>" + ($(data).find("#content-home").html()) + "</div>");
				});
		}
	})
}
