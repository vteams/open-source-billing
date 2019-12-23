module PaymentSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Searchable

    after_update { self.client.try(:touch); self.invoice.try(:touch)}
    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :payment_type, analyzer: 'english'
        indexes :payment_method, analyzer: 'english'
        indexes :notes, analyzer: 'english'
        indexes :client, type: :nested do
          [:organization_name, :first_name, :last_name, :email].each do |attribute|
            indexes attribute,  analyzer: 'english'
          end
        end
        indexes :invoice, type: :nested do
          indexes :invoice_number,  analyzer: 'english'
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

      query_base[:query][:bool][:must] << {nested: { path: 'invoice', nested: { path: 'clients', query: {query_string: { query: keyword[:client], fields: [:organization_name, :first_name, :last_name, :email] } }}} }if keys.include?('clients')
      query_base[:query][:bool][:must] << {nested: { path: 'invoice', query: {query_string: { query: keyword[:invoice], fields: [:invoice_number] }}}} if keys.include?('invoice')

      if keys.include?('payment_type') or keys.include?('payment_method') or keys.include?('notes')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:payment_method], fields: [:payment_method] }} if keys.include?('payment_method')
        query_base[:query][:bool][:must] << {query_string: { query: keyword[:notes], fields: [:notes] }} if keys.include?('notes')
      end

      query_base
    end

    def as_indexed_json(options={})
      self.as_json(
          only: [:payment_type, :payment_method, :notes],
          include: {
              client: { only: [:first_name, :last_name, :email, :organization_name]},
              invoice: { only: :invoice_number }
          })
    end

    def self.filter_options
      {
          filter_box: [
              {key: :payment_method, label: 'Payment Type'},
              {key: :notes,label:'Notes'},
              {key: :client, label: 'Client'},
              {key: :invoice, label: 'Invoice Number'}
          ]
      }
    end

    def self.sql_search(keyword)
      query = []
      keyword.each do |key,val|
        if key.eql?('payment_type') or key.eql?('payment_method') or key.eql?('notes')
          query << "payments.#{key} like '#{val}%'"
        end
        if key.eql?('clients')
          query << "(clients.first_name like '#{val}%' or clients.last_name like '#{val}%' or clients.email like '#{keyword[:client]}%' or clients.organization_name like '#{val}%')"
        end
        if key.eql?('invoice')
          query << "(invoices.invoice_number like '#{val}%')"
        end
      end
      query = query.join(" AND ")
      return joins(invoice: :client).where(query).uniq
    end

  end
end