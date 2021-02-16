// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You"re encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it"ll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "core-js/stable"
import "regenerator-runtime/runtime"
require("channels")
require("jquery")
const _ = require("libs/underscore.js")
require("libs/backbone.js")
require("backbone/index.js")

Rails.start()
Turbolinks.start()
ActiveStorage.start()
Backbone.history.start()

window.jQuery = $;
window.$ = $;
window.underscore = _;
window._ = _;