window.app = {collections: {}, models: {}, views: {}, functions: {}}

require("backbone/model.js")
require("backbone/views/users.js")
require("backbone/views/guilds.js")
require("backbone/views/tournaments.js")
require("backbone/views/wars.js")
require("backbone/router.js")
require("backbone/views/index.js");
require("backbone/custom.js");

new window.app.ApplicationRouter();
