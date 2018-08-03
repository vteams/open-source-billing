module SearchHelper

  def filter_box_for(filter_options={})
    id = "invoices_filter_box"
    style = ""
    data = {}
    data[:filter_fields] = filter_options.length == 0 ? eval(controller_name.eql?('sub_users') ? 'User' : controller_name.classify).filter_options[:filter_box] : filter_options[:filter_box]
    data[:filter_pre_populate] = params[:search]
    content_tag(:input, '', type: 'hidden', id: id, class: 'form-control hd-filter-box', style: style, data: data)
  end

  def search_available_in?(controller)
    %w(invoices estimates projects staffs tasks expenses clients sub_users companies payments taxes items).include?(controller)
  end
  
end