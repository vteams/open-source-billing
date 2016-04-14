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
    jQuery('#log_project_id').live("click", function() {
        return hidePopover(jQuery("#log_project_id"));
    });
    jQuery('#log_task_id').live("click", function() {
        return hidePopover(jQuery("#log_task_id"));
    });
    jQuery('#log_hours').live("click", function() {
        return hidePopover(jQuery("#log_hours"));
    });

    jQuery('.generate_invoice_btn').live("click", function (){
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
    jQuery(".log-submit-btn").live("click", function () {
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
        if (date === "") {
            applyPopover(jQuery("#log_date"), "bottomMiddle", "topLeft", "Select a date from the calendar");
            flag = false;
        } else {
            hidePopover(jQuery("#log_date"))
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
        } else {
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