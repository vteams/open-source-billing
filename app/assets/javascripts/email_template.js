$(document).ready( function() {
    $('#email_template_custom_fields li').click(function(evt) {
        var custom_token = $(this).find('.custom_field_token').text();
        var subject_focused = jQuery("#email_template_subject").is(":focus");
        var tiny_focused = jQuery("#email_template_body_ifr").is(":focus");
        if(subject_focused)
        {$("#email_template_subject").insertAtCaret(custom_token);}
        else if(tiny_focused) {
            tinyMCE.execCommand('mceInsertContent',false,custom_token);
        }
        return evt.stopImmediatePropagation();
    });

    $("#email_template_custom_fields li").draggable({helper: 'clone'});
    $("#email_template_subject, .mce-container").droppable({
        accept: "#email_template_custom_fields li",
        drop: function(ev, ui) {
            var custom_token = ui.draggable.find('.custom_field_token').text()
            $(this).insertAtCaret(custom_token);

        }
    });
});
$.fn.insertAtCaret = function (myValue) {
    return this.each(function(){
//IE support
        if (document.selection) {
            this.focus();
            sel = document.selection.createRange();
            sel.text = myValue;
            this.focus();
        }
//MOZILLA / NETSCAPE support
        else if (this.selectionStart || this.selectionStart == '0') {
            var startPos = this.selectionStart;
            var endPos = this.selectionEnd;
            var scrollTop = this.scrollTop;
            this.value = this.value.substring(0, startPos)+ myValue+ this.value.substring(endPos,this.value.length);
            this.focus();
            this.selectionStart = startPos + myValue.length;
            this.selectionEnd = startPos + myValue.length;
            this.scrollTop = scrollTop;
        } else {
            this.value += myValue;
            this.focus();
        }
    });
};


