module TaskSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable

    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :name, analyzer: 'english'
        indexes :description, analyzer: 'english'
      end
    end

    def self.search(keyword)
      if check_connection
        return self.__elasticsearch__.search query(keyword)
      else
        sql_search_class = SqlSearch.new
        sql_search_class.get_search(keyword,self)
        sql_search_class
      end
    end

    def self.query(keyword)
      keys = keyword.keys
      query_base= {query: {bool: {must: []}}}
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:name], fields: [:name] }} if keys.include?('name')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:description], fields: [:description] }} if keys.include?('description')
      query_base
    end


    def self.filter_options
      {
          filter_box: [
              {key: :name, label: 'Name'},
              {key: :description, label: 'Description'}
          ]
      }
    end

    def self.sql_search(keyword)
      query = []
      keyword.each do |key,val|
        query << "#{key} like '#{val}%'"
      end
      query = query.join(" AND ")
      return where(query)
    end

  end

end
