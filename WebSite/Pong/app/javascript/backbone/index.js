window.app = {collections: {}, models: {}, views: {}}

require("backbone/model.js")
require("backbone/views/view.js")
require("backbone/views/guilds.js")
require("backbone/views/tournaments.js")
require("backbone/router.js")

new window.app.ApplicationRouter();
