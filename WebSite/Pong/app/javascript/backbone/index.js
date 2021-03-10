window.app = {collections: {}, models: {}, views: {}}

require("backbone/model.js")
require("backbone/views/users.js")
require("backbone/views/guilds.js")
require("backbone/views/tournaments.js")
require("backbone/router.js")

new window.app.ApplicationRouter();
