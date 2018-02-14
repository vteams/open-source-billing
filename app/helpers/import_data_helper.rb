module ImportDataHelper
  def remove_url_path_from_sub_domain(params)
    params[:freshbooks][:account_url] = params[:freshbooks][:account_url].partition('.com').first + '.com'
  end
end
