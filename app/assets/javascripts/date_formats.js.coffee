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
      when '%m/%d/%y'
        format = 'mm/dd/y'
      when '%m/%d/%Y'
        format = 'mm/dd/yy'
      when '%d/%m/%y'
        format = 'dd/mm/y'
      when '%d/%m/%Y'
        format = 'dd/mm/yy'
      when '%y-%m-%d'
        format = 'y-mm-dd'
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
      when '%m/%d/%y'
        year = String(year).substr(2,3)
        date = "#{month}/#{day}/#{year}"
      when '%m/%d/%Y'
        date = "#{month}/#{day}/#{year}"
      when '%d/%m/%y'
        year = String(year).substr(2,3)
        date = "#{day}/#{month}/#{year}"
      when '%d/%m/%Y'
        date = "#{day}/#{month}/#{year}"
      when '%y-%m-%d'
        year = String(year).substr(2,3)
        date = "#{year}-#{month}-#{day}"
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
      when '%m/%d/%y'
        day = date.split('/')[1]
        month = date.split('/')[0]
        year = date.split('/')[2]
      when '%m/%d/%Y'
        day = date.split('/')[1]
        month = date.split('/')[0]
        year = date.split('/')[2]
      when '%d/%m/%y'
        day = date.split('/')[0]
        month = date.split('/')[1]
        year = date.split('/')[2]
      when '%d/%m/%Y'
        day = date.split('/')[0]
        month = date.split('/')[1]
        year = date.split('/')[2]
      when '%y-%m-%d'
        day = date.split('-')[2]
        month = date.split('-')[1]
        year=date.split('-')[0]
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
      jQuery.datepicker.parseDate @format(), date
      returnState = true
    catch err
      returnState = false
    returnState


window.DateFormats = DateFormats