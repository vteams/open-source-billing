$(document).ready(function() {

    var applyPopover, hidePopover;
    applyPopover = function (elem, position, corner, message) {
        elem.qtip({
            content: {
                text: message
            },
            show: {
                event: false
            },
            hide: {
                event: false
            },
            position: {
                at: position
            },
            style: {
                tip: {
                    corner: corner
                }
            }
        });
        elem.qtip().show();
        return elem.focus();
    };
    hidePopover = function (elem) {
        return elem.qtip("hide");
    };
    jQuery('body').on("click", "#log_project_id", function() {
        return hidePopover(jQuery("#log_project_id"));
    });
    jQuery('body').on("click", "#log_task_id", function() {
        return hidePopover(jQuery("#log_task_id"));
    });
    jQuery('body').on("click", "#log_hours", function() {
        return hidePopover(jQuery("#log_hours"));
    });

    jQuery("body").on('keypress', "#log_notes",function(e) {
        var tval = $('textarea').val(), tlength = tval.length, max = 400, remain = parseInt(max - tlength);
        $('.text-limit').text(remain + "  characters remaining" );
    });


    jQuery('body').on("click", ".generate_invoice_btn", function (){
        project_id = jQuery("#project_id").val();
        flag = true;
        if (project_id === "") {
            applyPopover(jQuery("#project_id"), "bottomMiddle", "topLeft", "Select a project");
            flag = false;
        }
        else
            hidePopover(jQuery("#project_id"));

        return flag;

    });

    $('#log_date').val($.datepicker.formatDate('yy-mm-dd', new Date()));
    jQuery("body").on("click", ".log-submit-btn", function () {
        var date, project_id, task_id, hours;
        date = jQuery("#log_date").val();
        project_id = jQuery("#log_project_id").val();
        task_id = jQuery("#log_task_id").val();
        hours = jQuery("#log_hours").val();
        flag = true;
        window.valid = 0;
        $(".frm_week input[type=number]").filter(function () {
            if ($.trim($(this).val()).length == 0) window.valid+=1;
        });

        if (window.valid == 7){
            applyPopover(jQuery("#hours_div"), "bottomMiddle", "topLeft", "Enter hours");
            flag = false;
        }else {
            hidePopover(jQuery("#hours_div"))
        }
        if (project_id === "") {
            applyPopover(jQuery("#log_project_id"), "bottomMiddle", "topLeft", "Select a project");
            flag = false;
        } else {
            hidePopover(jQuery("#log_project_id"))
        }
        if (task_id === "") {
            applyPopover(jQuery("#log_task_id"), "bottomMiddle", "topLeft", "Select a task");
            flag = false;
        } else {
            hidePopover(jQuery("#log_task_id"))
        }
        if (hours === "") {
            applyPopover(jQuery("#log_hours"), "bottomMiddle", "topLeft", "Enter hours");
            flag = false;
        }
        else if(hours < 0){
            applyPopover(jQuery("#log_hours"), "bottomMiddle", "topLeft", "Enter hours value greater than or equal to 0");
            flag = false;
        }
        else {
            hidePopover(jQuery("#log_hours"))
        }
        if (flag) {
            return true;
        }
        else {
            return false;
        }
    });

    return $(document).on('change', '#log_project_id', function (evt) {
        return $.ajax('/logs/update_tasks', {
            type: 'GET',
            dataType: 'script',
            data: {
                project_id: $("#log_project_id option:selected").val()
            }
        });
    });



});