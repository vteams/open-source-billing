class DateFormats
  @server_format: ->
    if gon? and gon.dateformat
      gon.dateformat
    else
      '%Y-%m-%d'
  @format: ->
    format = 'yyyy-mm-dd'
    s_format = @server_format()
    switch s_format
      when '%d-%b-%Y'
        format = 'dd-mmm-yyyy'
      when '%m/%d/%Y'
        format = 'mm/dd/yyyy'
      when '%d/%m/%Y'
        format = 'dd/mm/yyyy'
      when '%Y-%m-%d'
        format = 'yyyy-mm-dd'
      else
        format = 'yyyy-mm-dd'
    format

  @jqueryFormat: ->
    format = 'yyyy-mm-dd'
    s_format = @server_format()
    switch s_format
      when '%d-%b-%Y'
        format = 'dd-M-yy'
      when '%m/%d/%Y'
        format = 'mm/dd/yy'
      when '%d/%m/%Y'
        format = 'dd/mm/yy'
      when '%Y-%m-%d'
        format = 'yy-mm-dd'
      else
        format = 'yy-mm-dd'
    format

  @get_formated_date: (date) ->
    year = date.split('-')[0]
    month = date.split('-')[1]
    day = date.split('-')[2]
    format = @server_format()
    switch format
      when '%d-%b-%Y'
        date = "#{day}-#{moment(date).format('MMM')}-#{year}"
      when '%m/%d/%Y'
        date = "#{month}/#{day}/#{year}"
      when '%d/%m/%Y'
        date = "#{day}/#{month}/#{year}"
      when '%Y-%m-%d'
        date = "#{year}-#{month}-#{day}"
      else
        date = "#{year}-#{month}-#{day}"
    date
  @get_original_date: (date = null) ->
    date = new Date() unless date
    date_format = @server_format()
    year = 2015
    month = 4
    day = 15
    switch date_format
      when '%d-%b-%Y'
        month = date.split('-')[1]
        year = date.split('-')[2]
        day = date.split('-')[0]
      when '%m/%d/%Y'
        day = date.split('/')[1]
        month = date.split('/')[0]
        year = date.split('/')[2]
      when '%d/%m/%Y'
        day = date.split('/')[0]
        month = date.split('/')[1]
        year = date.split('/')[2]
      when '%Y-%m-%d'
        day = date.split('-')[2]
        month = date.split('-')[1]
        year = date.split('-')[0]
      else
        day = date.split('/')[2]
        month = date.split('/')[1]
        year = date.split('/')[0]
    #handling year
    current_year = String((new Date()).getFullYear())
    if String(year).length == 2
      year = "#{current_year.substring(0,2)}#{year}"
    "#{year}-#{month}-#{day}"

  @add_days_in_formated_date: (date=null,days=0) ->
    if date
      date = new Date(@get_original_date(date))
    else
      date = new Date()
    date.setDate(date.getDate() + days)
    year = date.getFullYear()
    month = date.getMonth()+1
    day = date.getDate()
    if String(month).length < 2
      month = "0"+String(month)
    if String(day).length < 2
      day = "0"+String(day)
    date = "#{year}-#{month}-#{day}"
    date = @get_formated_date(date)
    date

  @validate_date:(date = null) ->
    returnState = false
    try
      jQuery.datepicker.parseDate @jqueryFormat(), date
      returnState = true
    catch err
      returnState = false
    returnState

  @get_next_issue_date:(repetition, time) ->
    range = undefined
    if time=="Weekly"
      range = 7
    else if time == "Monthly"
      range = 30
    else if time == "Yearly"
      range = 365

    frequency = repetition * range
    frequency


window.DateFormats = DateFormats