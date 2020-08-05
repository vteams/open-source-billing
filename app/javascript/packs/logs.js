$(document).ready(function() {
    // $('select').material_select();
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
    initLogFormValidation();

    jQuery('.generate_invoice_btn').on("click", function (){
        project_id = jQuery("#project_id").val();
        flag = true;
        if (project_id === "") {
            applyPopover(jQuery("#project_id"), "bottomMiddle", "topLeft", I18n.t('views.logs.select_project'));
            flag = false;
        }
        else
            hidePopover(jQuery("#project_id"));

        return flag;

    });
});

function initLogFormValidation() {
  jQuery('#log_task_id').on("change", function() {
    hidePopover(jQuery("#log_task_id").parents('.select-wrapper'));
  });
  jQuery('#log_hours').on("keypress", function() {
    return hidePopover(jQuery("#log_hours"));
  });
  jQuery("#log_notes").on('keypress',function(e) {
    var tval = $('textarea').val(), tlength = tval.length, max = 400, remain = parseInt(max - tlength);
    $('.text-limit').text(remain + "  characters remaining" );
  });
  jQuery(".log-submit-btn").on("click", function () {
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

    if (project_id === "") {
      applyPopover(jQuery("#log_project_id").parents('.select-wrapper'), "bottomMiddle", "topLeft", I18n.t('views.logs.select_project'));
      flag = false;
    } else {
      hidePopover(jQuery("#log_project_id").parents('.select-wrapper'));
    }
    if (task_id === "") {
      applyPopover(jQuery("#log_task_id").parents('.select-wrapper'), "bottomMiddle", "topLeft", I18n.t('views.logs.select_task'));
      flag = false;
    } else {
      hidePopover(jQuery("#log_task_id").parents('.select-wrapper'));
    }
    if (hours === "") {
      applyPopover(jQuery("#log_hours"), "bottomMiddle", "topLeft", I18n.t('views.logs.enter_hours'));
      flag = false;
    }
    else if(hours < 0){
      applyPopover(jQuery("#log_hours"), "bottomMiddle", "topLeft", I18n.t('views.logs.hours_greated_than_zero'));
      flag = false;
    }
    else {
      hidePopover(jQuery("#log_hours"))
    }
    if (window.valid == 7){
      applyPopover(jQuery("#hours_div"), "bottomMiddle", "topLeft", I18n.t('views.logs.enter_hours'));
      flag = false;
    }else {
      hidePopover(jQuery("#hours_div"));
    }

    return flag;
  });

  $('#log_date').val($.datepicker.formatDate('yy-mm-dd', new Date()));

  return $(document).on('change', '#log_project_id', function (evt) {
    hidePopover(jQuery("#log_project_id").parents('.select-wrapper'));
    return $.ajax('/logs/update_tasks', {
      type: 'GET',
      dataType: 'script',
      data: {
        project_id: $("#log_project_id option:selected").val()
      }
    });
  });
}