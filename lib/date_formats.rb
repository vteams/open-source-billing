module DateFormats
  def invoice_date=(date)
    super(custom_date_format(date))
  end
  def expense_date=(date)
    super(custom_date_format(date))
  end

  def due_date=(date)
    super(custom_date_format(date))
  end

  def payment_date=(date)
    super(custom_date_format(date))
  end

  def first_invoice_date=(date)
    super(custom_date_format(date))
  end

  def first_invoice_date
    date = super
    return '' if date.nil?
    date.to_date.strftime(date_format)
  end

  def expense_date
    date = super
    return '' if date.nil?
    date.to_date.strftime(date_format)
  end

  def payment_date
    date = super
    return '' if date.nil?
    date.to_date.strftime(date_format)
  end

  def invoice_date
    date = super
    return '' if date.nil?
    date.to_date.strftime(date_format)
  end

  def due_date
    date = super
    return '' if date.nil?
    date.to_date.strftime(date_format)
  end

  def custom_date_format(date)
    date = (date.class == Date or date.class == ActiveSupport::TimeWithZone) ? date.to_date.to_s : date
    user_date_format = date_format
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

    #handling year
    current_year = Date.today.year
    if year.to_s.length == 2
      year = "#{current_year.to_s[0..1]}#{year}"
    end
    formatted_date ="#{year}-#{month}-#{day}".to_date.to_s
    if formatted_date.to_s[0] == '-'
      formatted_date = formatted_date.to_s[1..formatted_date.to_s.length-1]
    end
    formatted_date.to_date
  end

  def date_format
    user = User.current
    if user.nil?
      '%Y-%m-%d'
    elsif user.settings.date_format.present?
      user.settings.date_format
    else
      user.settings.date_format = '%Y-%m-%d'
    end
  end

  def set_filter_date_formats(options={})
    if options[:from_date].present?
      options[:from_date] = custom_date_format(options[:from_date]).to_s
    end
    if options[:to_date].present?
      options[:to_date] = custom_date_format(options[:to_date]).to_s
    end
    if options[:invoice_first_date].present?
      options[:invoice_first_date] = custom_date_format(options[:invoice_first_date]).to_s
    end
    options
  end
end
