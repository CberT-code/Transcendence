// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "jquery"
import "underscore-rails"
require("packs/backbone.js")

Rails.start()
Turbolinks.start()
ActiveStorage.start()
Backbone.start()

var PongApp = {
    Models: {},
    Collections, {},
    Views: {},
    Routers: {
        "account":  "account",
    },
    initialize: function () {
        new PongApp.Routers.Tasks();
        Backbone.history.start();
        alert(1);
    }
};

PongApp.start()
