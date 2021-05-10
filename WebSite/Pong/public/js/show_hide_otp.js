var otp = $('#content-user #player_data').data('otp');

console.log("otp data : " + otp);
if (otp) {
	$('#content-user #otp_disable_form').show();
	$('#content-user #otp_disable_button').show();
	$('#content-user #otp_confirm_form').hide();
	$('#content-user #otp_confirm_button').hide();
	$('#content-user #otp_enable').hide();
	$('#content-user #otp_qrcode').hide();
}
else {
	$('#content-user #otp_disable_form').hide();
	$('#content-user #otp_disable_button').hide();
	$('#content-user #otp_confirm_form').hide();
	$('#content-user #otp_confirm_button').hide();
	$('#content-user #otp_enable').show();
	$('#content-user #otp_qrcode').hide();
}