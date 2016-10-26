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
    $('#log_project_id').on("click",null, function() {
        return hidePopover($("#log_project_id"));
    });
    $('#log_task_id').on("click",null, function() {
        return hidePopover($("#log_task_id"));
    });
    $('#log_hours').on("click",null, function() {
        return hidePopover($("#log_hours"));
    });

    $("#log_notes").on('keypress',null, function(e) {
        var tval = $('textarea').val(), tlength = tval.length, max = 400, remain = parseInt(max - tlength);
        $('.text-limit').text(remain + "  characters remaining" );
    });


    $('.generate_invoice_btn').on("click",null, function (){
        project_id = $("#project_id").val();
        flag = true;
        if (project_id === "") {
            applyPopover($("#project_id"), "bottomMiddle", "topLeft", "Select a project");
            flag = false;
        }
        else
            hidePopover($("#project_id"));

        return flag;

    });

    $('#log_date').val($.datepicker.formatDate('yy-mm-dd', new Date()));
    $(".log-submit-btn").on("click",null, function () {
        var date, project_id, task_id, hours;
        date = $("#log_date").val();
        project_id = $("#log_project_id").val();
        task_id = $("#log_task_id").val();
        hours = $("#log_hours").val();
        flag = true;
        window.valid = 0;
        $(".frm_week input[type=number]").filter(function () {
            if ($.trim($(this).val()).length == 0) window.valid+=1;
        });

        if (window.valid == 7){
            applyPopover($("#hours_div"), "bottomMiddle", "topLeft", "Enter hours");
            flag = false;
        }else {
            hidePopover($("#hours_div"))
        }
        if (project_id === "") {
            applyPopover($("#log_project_id"), "bottomMiddle", "topLeft", "Select a project");
            flag = false;
        } else {
            hidePopover($("#log_project_id"))
        }
        if (task_id === "") {
            applyPopover($("#log_task_id"), "bottomMiddle", "topLeft", "Select a task");
            flag = false;
        } else {
            hidePopover($("#log_task_id"))
        }
        if (hours === "") {
            applyPopover($("#log_hours"), "bottomMiddle", "topLeft", "Enter hours");
            flag = false;
        }
        else if(hours < 0){
            applyPopover($("#log_hours"), "bottomMiddle", "topLeft", "Enter hours value greater than or equal to 0");
            flag = false;
        }
        else {
            hidePopover($("#log_hours"))
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
