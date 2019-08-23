module UserSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable
    # after_update { self.role.touch }

    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :user_name,  analyzer: 'english'
        indexes :email,  analyzer: 'english'
        indexes :roles, type: :nested do
          indexes :name,  analyzer: 'english'
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
      query_base[:query][:bool][:must] << {nested: { path: 'roles', query: {query_string: { query: keyword[:role], fields: [:name] } }}} if keys.include?('role')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:user_name], fields: [:user_name] }} if keys.include?('user_name')
      query_base[:query][:bool][:must] << {query_string: { query: keyword[:email], fields: [:email] }} if keys.include?('email')
      query_base
    end

    def as_indexed_json(options={})
      self.as_json(
          only: [:user_name, :email],
          include: {
              roles: { only: [:name]}
          })
    end

    def self.filter_options
      {
          filter_box: [
              {key: :user_name, label: 'Full Name'},
              {key: :email, label: 'email'},
              {key: :role, label: 'role'}
          ]
      }
    end

    def self.sql_search(keyword)
      query = []
      keyword.each do |key,val|
        if key.eql?('user_name') or key.eql?('email')
          query << "users.#{key} like '#{val}%'"
        end
        if key.eql?('role')
          query << "(roles.name like '#{val}%')"
        end

      end
      query = query.join(" AND ")
      return joins(:roles).where(query).uniq
    end
  end

end
