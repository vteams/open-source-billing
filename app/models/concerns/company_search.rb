module CompanySearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable
    MAPPING_FIELDS = %w(company_name contact_name country email)

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
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:company_name], fields: [:company_name] }} if keys.include?('company_name')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:contact_name], fields: [:contact_name] }} if keys.include?('contact_name')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:country], fields: [:country] }} if keys.include?('country')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:email], fields: [:email] }} if keys.include?('email')
      query_base
    end

    def self.filter_options
      {
          filter_box: [
              {key: :company_name, label: 'Company Name'},
              {key: :contact_name, label: 'Contact Name'},
              {key: :country, label: 'Country'},
              {key: :email, label: 'email'}
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
