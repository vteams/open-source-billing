module EstimateSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable

    after_update { self.client.try(:touch); self.estimate_line_items.map(&:touch)}
    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :estimate_number, analyzer: 'english'
        indexes :notes, analyzer: 'english'
        indexes :status, analyzer: 'english'
        indexes :client, type: :nested do
          [:organization_name, :first_name, :last_name, :email].each do |attribute|
            indexes attribute,  analyzer: 'english'
          end
        end
        indexes :estimate_line_items, type: :nested do
          [:item_name, :item_description].each do |attribute|
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
      query_base[:query][:bool][:must] << {nested: { path: 'estimate_line_items', query: {query_string: { query: keyword[:estimate_line_items], fields: [:item_name, :item_description] }}}} if keys.include?('estimate_line_items')

      if keys.include?('estimate_number') or keys.include?('notes') or keys.include?('status')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:estimate_number], fields: [:estimate_number] }} if keys.include?('estimate_number')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:status], fields: [:status] }} if keys.include?('status')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:notes], fields: [:notes] }} if keys.include?('notes')
      end

      query_base
    end

    def as_indexed_json(options={})
      self.as_json(
          only: [:estimate_number, :notes, :status],
          include: {
              client: { only: [:first_name, :last_name, :email, :organization_name]},
              estimate_line_items: { only: [:item_name, :item_description]}
          })
    end

    def self.filter_options
      {
          filter_box: [
              {key: :estimate_number, label: 'Estimate Number'},
              {key: :status, label: 'Status'},
              {key: :notes,label:'Notes'},
              {key: :client, label: 'Client'},
              {key: :estimate_line_items, label: 'Line Items'}
          ]
      }
    end

    def self.sql_search(keyword)
      query = []
      keyword.each do |key,val|
        if key.eql?('estimate_number') or key.eql?('notes') or key.eql?('status')
          query << "#{key} like '#{val}%'"
        end
        if key.eql?('client')
          query << "(clients.first_name like '#{val}%' or clients.last_name like '#{val}%' or clients.email like '#{keyword[:client]}%' or clients.organization_name like '#{val}%')"
        end
        if key.eql?('estimate_line_items')
          query << "(invoice_line_items.item_name like '#{val}%' or invoice_line_items.item_description like '#{val}%')"
        end
      end
      query = query.join(" AND ")
      return joins(:client,:estimate_line_items).where(query).uniq
    end

  end
end