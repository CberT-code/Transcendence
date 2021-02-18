window.app = {collections: {}, models: {}, views: {}}

require("backbone/model.js")
require("backbone/view.js")
require("backbone/router.js")


new window.app.ApplicationRouter();
