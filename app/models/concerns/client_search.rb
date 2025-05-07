module ClientSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable
    MAPPING_FIELDS = %w(first_name last_name organization_name email)

    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        MAPPING_FIELDS.each do |column|
          indexes column.to_sym, analyzer: 'english'
        end
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
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:first_name], fields: [:first_name] }} if keys.include?('first_name')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:last_name], fields: [:last_name] }} if keys.include?('last_name')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:organization_name], fields: [:organization_name] }} if keys.include?('organization_name')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:email], fields: [:email] }} if keys.include?('email')
      query_base
    end

    def self.filter_options
      {
          filter_box: [
              {key: :first_name, label: 'First Name'},
              {key: :last_name, label: 'Last Name'},
              {key: :organization_name, label: 'Organization Name'},
              {key: :email, label: 'Email'}
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
