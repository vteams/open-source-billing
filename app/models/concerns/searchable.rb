module Searchable
  extend ActiveSupport::Concern

  included do
    before_save :elastic_fallback

    def elastic_fallback
      if self.class.check_connection
        self.__elasticsearch__.index_document
      end
    end

    def self.check_connection
      begin
         Net::HTTP.new('localhost',9200).get('/')
      rescue => e
        ExceptionNotifier.notify_exception(e)
        return false
      else
        return true
      end
    end

    Elasticsearch::Model.client = Elasticsearch::Client.new log: true

  end

end
