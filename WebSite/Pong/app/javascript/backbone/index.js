window.app = {collections: {}, models: {}, views: {}, functions: {}}

require("backbone/model.js");
require("backbone/views/index.js");
require("backbone/router.js");
require("backbone/custom.js");

new window.app.ApplicationRouter();
