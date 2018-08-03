class SqlSearch
  attr_accessor :records

  def get_search(keyword,model)
    self.records  = model.sql_search(keyword)
  end

end