window.app = {collections: {}, models: {}, views: {}}

require("backbone/model.js")
require("backbone/view.js")
require("backbone/router.js")

// TOKEN CSRF INTO HEADER FOR PROTECTION 
$.ajaxSetup({
    beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name=csrf-token]').attr('content'));
    }
});

new window.app.ApplicationRouter();
