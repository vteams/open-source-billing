module ProjectSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable

    after_update { self.client.try(:touch);self.manager.try(:touch)  }

    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :project_name, analyzer: 'english'
        indexes :client, type: :nested do
          [:organization_name, :first_name, :last_name, :email].each do |attribute|
            indexes attribute,  analyzer: 'english'
          end
        end
        indexes :manager, type: :nested do
          [:name, :email].each do |attribute|
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

      query_base[:query][:bool][:must] << {nested: { path: 'clients', query: {query_string: { query: keyword[:client], fields: [:organization_name, :first_name, :last_name, :email] } }}} if keys.include?('clients')
      query_base[:query][:bool][:must] << {nested: { path: 'manager', query: {query_string: { query: keyword[:manager], fields: [:name, :email] }}}} if keys.include?('manager')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:project_name], fields: [:project_name] }} if keys.include?('project_name')
      query_base
    end

    def as_indexed_json(options={})
      self.as_json(
              only: :project_name,
              include: {
                         client: { only: [:first_name, :last_name, :email, :organization_name]},
                         manager:{only: [:name, :email]}

          })
    end

    def self.filter_options
      {
          filter_box: [
              {key: :project_name, label: 'Project Name'},
              {key: :client, label: 'Client'},
              {key: :manager, label: 'Manager'}
          ]
      }
    end

    def self.sql_search(keyword)
      query = []
      keyword.each do |key,val|
        if key.eql?('project_name')
          query << "projects.#{key} like '%#{val}%'"
        end
        if key.eql?('clients')
          query << "(cc.first_name like '%#{val}%' or cc.last_name like '%#{val}%' or cc.email like '%#{keyword[:client]}%' or cc.organization_name like '%#{val}%')"
        end
        if key.eql?('manager')
          query << "(staffs.name like '%#{val}%' or staffs.email like '%#{val}%')"
        end
      end
      query = query.join(" AND ")
      return joins('LEFT OUTER JOIN clients as cc ON projects.client_id = cc.id').joins(:manager).where(query).uniq
    end

  end

end
