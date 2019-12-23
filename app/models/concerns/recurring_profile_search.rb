module RecurringProfileSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable

    after_update { self.client.try(:touch); self.recurring_profile_line_items.map(&:touch)}
    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :invoice_number, analyzer: 'english'
        indexes :frequency, analyzer: 'english'
        indexes :notes, analyzer: 'english'
        indexes :client, type: :nested do
          [:organization_name, :first_name, :last_name, :email].each do |attribute|
            indexes attribute,  analyzer: 'english'
          end
        end
        indexes :recurring_profile_line_items, type: :nested do
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

      query_base[:query][:bool][:must] << {nested: { path: 'clients', query: {query_string: { query: keyword[:client], fields: [:organization_name, :first_name, :last_name, :email] } }}} if keys.include?('clients')
      query_base[:query][:bool][:must] << {nested: { path: 'recurring_profile_line_items', query: {query_string: { query: keyword[:recurring_profile_line_items], fields: [:item_name, :item_description] }}}} if keys.include?('recurring_profile_line_items')

      if keys.include?('invoice_number') or keys.include?('notes') or keys.include?('frequency')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:invoice_number], fields: [:invoice_number] }} if keys.include?('invoice_number')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:notes], fields: [:notes] }} if keys.include?('notes')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:frequency], fields: [:frequency] }} if keys.include?('frequency')
      end

      query_base
    end

    def as_indexed_json(options={})
      self.as_json(
          only: [:invoice_number, :notes, :frequency],
          include: {
              client: { only: [:first_name, :last_name, :email, :organization_name]},
              recurring_profile_line_items: { only: [:item_name, :item_description]}
          })
    end

    def self.filter_options
      {
          filter_box: [
              {key: :invoice_number, label: 'Profile ID'},
              {key: :frequency,label:'Frequency'},
              {key: :notes,label:'Notes'},
              {key: :client, label: 'Client'},
              {key: :recurring_profile_line_items, label: 'Line Items'}
          ]
      }
    end

    def self.sql_search(keyword)
      query = []
      keyword.each do |key,val|
        if key.eql?('invoice_number') or key.eql?('frequency') or key.eql?('notes')
          query << "recurring_profiles.#{key} like '#{val}%'"
        end
        if key.eql?('clients')
          query << "(clients.first_name like '#{val}%' or clients.last_name like '#{val}%' or clients.email like '#{keyword[:client]}%' or clients.organization_name like '#{val}%')"
        end
        if key.eql?('recurring_profile_line_items')
          query << "(recurring_profile_line_items.item_name like '#{val}%' or recurring_profile_line_items.item_description like '#{val}%')"
        end
      end
      query = query.join(" AND ")
      return includes(:client).joins(:recurring_profile_line_items).where(query).uniq
    end

  end
end