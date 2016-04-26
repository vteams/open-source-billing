var clock
$(document).ready(function() {
    clock = $('.timer').FlipClock({
        autoStart: false,
        countdown: false

    });
    $('#timer_wrapper form#new_log').on('ajax:success', function(data){
        //alert('Log created successfully!');

    });

});
function start_timer(){
    if($('#log_hours').val() > 24 || $('#log_hours').val() < 0 ){
        applyPopover(jQuery('#log_hours'), 'bottomLeft', 'topLeft', 'Please enter a value between 0 and 24');
        return
    }
    hidePopover(jQuery('#log_hours'));
    clock.setTime(Math.abs($('#log_hours').val()* 3600));
    clock.start(function() {
        countdown: false
    });
    $('#log_hours').prop('disabled',true);
    $(".log-submit-btn").prop('disabled',true);

}
function stop_timer(){
    clock.stop();
    var time  = clock.getTime();
    $('#log_hours').val(Math.abs((time/3600).toFixed(3)))
    $('#log_hours').prop('disabled',false);
    $(".log-submit-btn").prop('disabled',false);
}
function reset_timer(){
    clock.reset();
    clock.stop();
    $('#log_hours').prop('disabled',false);
    $(".log-submit-btn").prop('disabled',false);
}

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