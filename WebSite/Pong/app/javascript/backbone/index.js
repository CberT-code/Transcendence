window.app = {collections: {}, models: {}, views: {}}

require("backbone/model.js");
require("backbone/views/index.js");
require("backbone/router.js");

new window.app.ApplicationRouter();
