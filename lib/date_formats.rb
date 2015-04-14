module DateFormats
  def invoice_date=(date)
    super(custom_date_format(date))
  end

  def due_date=(date)
    super(custom_date_format(date))
  end

  def custom_date_format(date)
    date = date.class == Date ? date.to_date.to_s : date
    user_date_format = get_date_format
    day = 1
    month = 2
    year = 2015
    case user_date_format
      when '%m/%d/%y'
        month, day, year = date.split('/')[0],date.split('/')[1],date.split('/')[2]
      when '%m/%d/%Y'
        month, day, year = date.split('/')[0],date.split('/')[1],date.split('/')[2]
      when '%d/%m/%y'
        day, month, year = date.split('/')[0],date.split('/')[1],date.split('/')[2]
      when '%d/%m/%Y'
        day, month, year = date.split('/')[0],date.split('/')[1],date.split('/')[2]
      when '%y-%m-%d'
        year, month, day = date.split('-')[0],date.split('-')[1],date.split('-')[2]
      when '%Y-%m-%d'
        year, month, day = date.split('-')[0],date.split('-')[1],date.split('-')[2]
      else
        year, month, day = date.split('-')[0],date.split('-')[1],date.split('-')[2]
      end
    "#{year}-#{month}-#{day}".to_date
  end

  def get_date_format
    user = User.current
    return '%Y-%m-%d' if user.nil?
    user.settings.date_format
  end
end
