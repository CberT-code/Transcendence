window.app = {collections: {}, models: {}, views: {}}

require("backbone/models/model.js")
require("backbone/view.js")
require("backbone/router.js")



new window.app.ApplicationRouter();
