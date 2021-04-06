window.app.ApplicationRouter = Backbone.Router.extend({
	initialize: function() {
		this.ViewAccount = new ViewAccount();
		this.ViewGuilds = new ViewGuilds();
		this.ViewWars = new ViewWars();
		this.ViewTournaments = new ViewTournaments();
		this.ViewChannel = new ViewChannel();
	},
	routes: {
	"": "home",
	"accounts": "accounts",
	"show_user/:id": "show_user",
	"tchat": "tchat",
	"play": "play",
	//guilds
	"guilds": "guilds",
	"new_guild": "new_guild",
	"show_guild/:id": "show_guild",
	//tournaments
	"tournaments": "tournaments",
	"new_tournament": "new_tournament",
	//wars
	"wars": "wars",
	"new_war": "new_war",
	"show_war/:id": "show_war",
	"edit_war/:id": "edit_war",
	"error/403": "error403",
},
home: function() {
	$.get("/").then(function(data){
	$("main").html("<div id='content-home'>" + ($(data).find("#content-home").html()) + "</div>");
	});
},

// ACCOUNTS
show_user: function(id) {
	$.get("/users/" +  id, { id: id}).then(function(data){
		$("main").html("<div id='content-user'>" + ($(data).find("#content-user").html()) + "</div>");
	});
},
accounts: function() {
	$.get("/users").then(function(data){
		$("main").html("<div id='content-users'>" + ($(data).find("#content-users").html()) + "</div>");
	});
},

// TCHAT
tchat: function() {
	$.get("/tchat").then(function(data){
		$("main").html("<div id='content-tchat'>" + ($(data).find("#content-tchat").html()) + "</div>");
	});
},

// GAME
play: function() {
	$.get("/play").then(function(data){
		$("main").html("<div id='content-play'>" + ($(data).find("#content-play").html()) + "</div>");
	});
},

// GUILDS
guilds: function() {
	$.get("/guilds").then(function(data){
		$("main").html("<div id='content-guilds'>" + ($(data).find("#content-guilds").html()) + "</div>");
	});
},
new_guild: function() {
	$.get("/guilds/new").then(function(data){
		$("main").html("<div id='content-new_guild'>" + ($(data).find("#content-new_guild").html()) + "</div>");
	});
},
show_guild: function(id) {
	$.get("/guilds/" +  id, { id: id}).then(function(data){
		$("main").html("<div id='content-guild'>" + ($(data).find("#content-guild").html()) + "</div>");
		$("#line-war").hide();
	});
},
// Tournaments
tournaments: function() {
	$.get("/tournaments").then(function(data){
		$("main").html("<div id='content-tournaments'>" + ($(data).find("#content-tournaments").html()) + "</div>");
	});
},
new_tournament: function() {
	$.get("/tournaments/new").then(function(data){
		$("main").html("<div id='content-new_tournament'>" + ($(data).find("#content-new_tournament").html()) + "</div>");
	});
},
// WARS
wars: function() {
	$.get("/wars").then(function(data){
		$("main").html("<div id='content-wars'>" + ($(data).find("#content-wars").html()) + "</div>");
	});
},
new_war: function() {
	$.get("/wars/new").then(function(data){
		$("main").html("<div id='content-new_war'>" + ($(data).find("#content-new_war").html()) + "</div>");
	});
},
show_war: function(id) {
	$.get("/wars/" +  id, { id: id}).then(function(data){
		$("main").html("<div id='content-war'>" + ($(data).find("#content-war").html()) + "</div>");
	});
},
edit_war: function(id) {
	$.get("/wars/" +  id + "/edit", { id: id}).then(function(data){
		$("main").html("<div id='content-war'>" + ($(data).find("#content-war").html()) + "</div>");
	});
},
error403: function(id) {
	$.get("/error/403").then(function(data){
		$("main").html("<div id='content-error'>" + ($(data).find("#content-error").html()) + "</div>");
	});
},
});