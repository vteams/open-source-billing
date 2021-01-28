module InvoiceSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable
    after_update { self.client.try(:touch);}
    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :invoice_number, analyzer: 'english'
        indexes :notes, analyzer: 'english'
        indexes :status, analyzer: 'english'
        indexes :client, type: :nested do
          [:organization_name, :first_name, :last_name, :email].each do |attribute|
            indexes attribute,  analyzer: 'english'
          end
        end
        indexes :invoice_line_items, type: :nested do
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
      query_base[:query][:bool][:must] << {nested: { path: 'invoice_line_items', query: {query_string: { query: keyword[:invoice_line_items], fields: [:item_name, :item_description] }}}} if keys.include?('invoice_line_items')

      if keys.include?('invoice_number') or keys.include?('notes') or keys.include?('status')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:invoice_number], fields: [:invoice_number] }} if keys.include?('invoice_number')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:status], fields: [:status] }} if keys.include?('status')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:notes], fields: [:notes] }} if keys.include?('notes')
      end

      query_base
    end

    def as_indexed_json(options={})
      self.as_json(
          only: [:invoice_number, :notes, :status],
          include: {
              client: { only: [:first_name, :last_name, :email, :organization_name]},
              invoice_line_items: { only: [:item_name, :item_description]}
          })
    end

    def self.filter_options
      {
          filter_box: [
              {key: :invoice_number, label: 'Invoice Number'},
              {key: :status, label: 'Status'},
              {key: :notes,label:'Notes'},
              {key: :client, label: 'Client'},
              {key: :invoice_line_items, label: 'Line Items'}
          ]
      }
    end

    def self.sql_search(keyword)
      query = []
      keyword.each do |key,val|
        if key.eql?('invoice_number') or key.eql?('notes') or key.eql?('status')
          query << "invoices.#{key} like '%#{val}%'"
        end
        if key.eql?('client')
          query << "(cc.first_name like '%#{val}%' or cc.last_name like '%#{val}%' or cc.email like '%#{keyword[:client]}%' or cc.organization_name like '%#{val}%')"
        end
        if key.eql?('invoice_line_items')
          query << "(invoice_line_items.item_name like '%#{val}%' or invoice_line_items.item_description like '%#{val}%')"
        end
      end
      query = query.join(" AND ")
      return joins('LEFT OUTER JOIN clients as cc ON invoices.client_id = cc.id').joins(:invoice_line_items).where(query).uniq
    end

  end
end