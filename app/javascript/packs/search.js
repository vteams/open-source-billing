// filterbox = require('./filter_box.js').filterbox
$(document).ready(function(){
    if($(".search").length > 0)
        window.filterbox= new FilterBox('.hd-filter-box');
});