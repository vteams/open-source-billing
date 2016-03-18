var clock
$(document).ready(function() {
    clock = $('.timer').FlipClock({
        autoStart: false,
        countdown: false

    });
    $('#timer_wrapper form#new_log').on('ajax:success', function(data){
        //alert('Log created successfully!');

    })
});
function start_timer(){
    clock.setTime($('#log_hours').val()* 3600);
    clock.start(function() {
        countdown: false
    });
    $('#log_hours').prop('disabled',true);

}
function stop_timer(){
    clock.stop();
    var time  = clock.getTime();
    $('#log_hours').val((time/3600).toFixed(2))
    $('#log_hours').prop('disabled',false);
}
function reset_timer(){
    clock.reset();
    clock.stop();
    $('#log_hours').prop('disabled',false);
}
