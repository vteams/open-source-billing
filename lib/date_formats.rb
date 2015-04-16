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
    separator = if date.include?('/')
                  '/'
                else
                  '-'
                end
    day = 1
    month = 2
    year = 2015
    if user_date_format.present?
      if user_date_format == '%m/%d/%y'
        month, day, year = date.split('/')[0],date.split('/')[1],date.split('/')[2]
      elsif user_date_format ==  '%m/%d/%Y'
        month, day, year = date.split('/')[0],date.split('/')[1],date.split('/')[2]
      elsif user_date_format == '%d/%m/%y'
        day, month, year = date.split('/')[0],date.split('/')[1],date.split('/')[2]
      elsif user_date_format == '%d/%m/%Y' and separator == '-'
        year, month, day = date.split('-')[0],date.split('-')[1],date.split('-')[2]
      elsif user_date_format == '%d/%m/%Y'
        day, month, year = date.split('/')[0],date.split('/')[1],date.split('/')[2]
      elsif user_date_format == '%y-%m-%d'
        year, month, day = date.split('-')[0],date.split('-')[1],date.split('-')[2]
      elsif user_date_format == '%Y-%m-%d'
        year, month, day = date.split('-')[0],date.split('-')[1],date.split('-')[2]
      else
        year, month, day = date.split('-')[0],date.split('-')[1],date.split('-')[2]
      end
      "#{year}-#{month}-#{day}".to_s
    end

    #handling year
    current_year = Date.today.year
    if year_is_in_short_form? and year.to_s.length == 2
      year = "#{current_year.to_s[0..1]}#{year}"
    elsif year_is_in_short_form? and year.to_s.length != 2
      year =  "#{year.to_s[-2..-1]}"
    end
    "#{year}-#{month}-#{day}".to_s
  end

  def year_is_in_short_form?
     date_format = get_date_format
     formatted_array = date_format.split("")
     status = false
     formatted_array.each_with_index do |value, index|
       if formatted_array[index] == '%' and formatted_array[index + 1] == 'y'
         status = true
       end
     end
    status
  end

  def get_date_format
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
    options
  end
end
