module ExpenseSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable

    after_update { self.client.try(:touch); self.category.try(:touch); self.tax1.try(:touch); self.tax2.try(:touch)}
    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :note, analyzer: 'english'
        indexes :client, type: :nested do
          [:organization_name, :first_name, :last_name, :email].each do |attribute|
            indexes attribute,  analyzer: 'english'
          end
        end
        indexes :category, type: :nested do
          [:name].each do |attribute|
            indexes attribute,  analyzer: 'english'
          end
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

      query_base[:query][:bool][:must] << {nested: { path: 'client', query: {query_string: { query: keyword[:client], fields: [:organization_name, :first_name, :last_name, :email] } }}} if keys.include?('client')
      query_base[:query][:bool][:must] << {nested: { path: 'category', query: {query_string: { query: keyword[:category], fields: [:name] } }}} if keys.include?('category')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:note], fields: [:note] }} if keys.include?('note')
      query_base
    end

    def as_indexed_json(options={})
      self.as_json(
          only: [:note],
          include: {
              client: { only: [:first_name, :last_name, :email, :organization_name]},
              category: {only: [:name]}
          })
    end

    def self.filter_options
      {
          filter_box: [
              {key: :note, label: 'Notes'},
              {key: :client, label: 'Client'},
              {key: :category, label: 'Category'}

          ]
      }
    end

    def self.sql_search(keyword)
      query = []
      keyword.each do |key,val|
        if key.eql?('note')
          query << "expenses.#{key} like '#{val}%'"
        end
        if key.eql?('client')
          query << "(clients.first_name like '#{val}%' or clients.last_name like '#{val}%' or clients.email like '#{keyword[:client]}%' or clients.organization_name like '#{val}%')"
        end
        if key.eql?('category')
          query << "(expense_categories.name like '#{val}%')"
        end
      end
      query = query.join(" AND ")
      return joins(:client, :category).where(query).uniq
    end

  end
end