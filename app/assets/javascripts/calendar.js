$(document).ready(function() {

    // page is now ready, initialize the calendar...

    //
    $('#calendar').fullCalendar({
        dayClick: function(date, jsEvent, view) {
           // alert('a day has been clicked!');
           // $.ajax({
           //     dataType: 'script',
           //     type: 'GET',
           //     url: '/calendar_entries/new'
           //   });
            $('#log_date').val(date.format())

        //alert('Clicked on: ' + date.format());
        },
        eventClick: function(event) {
            //window.open(event.showUrl)
            alert('a day has been clicked!');
        }

    })


});