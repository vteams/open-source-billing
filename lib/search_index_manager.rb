class SearchIndexManager
  INDEX_NAME = "osb_1_#{Rails.env}".freeze
  INDEXED_MODELS = [Client, Item, Tax, Task, Staff, Company, User, Project, Invoice, Estimate, Payment, Expense, InvoiceLineItem].freeze

  def self.create_index(options = {})
    settings = INDEXED_MODELS.map(&:settings).reduce({}, &:merge)
    mappings = INDEXED_MODELS.map(&:mappings).reduce({}, &:merge)

    if options[:force]
      delete_index
    end

    create index: INDEX_NAME, body: { settings: settings, mappings: mappings }
  end

  def self.delete_index
    if exists? index: INDEX_NAME
      delete index: INDEX_NAME
    end
  end

  def self.refresh_index
    if exists? index: INDEX_NAME
      refresh index: INDEX_NAME
    end
  end

  def self.import(options = {})
    models_to_index = options[:models] || INDEXED_MODELS

    if (models_to_index - INDEXED_MODELS).present?
      raise TypeError, "The :models option cannot contain non-indexed models"
    end

    models_to_index.each do |model|
      model.import batch_size: 1_000
    end
  end

  class << self
    private

    delegate :create, :exists?, :delete, :refresh, to: :indices

    def indices
      Elasticsearch::Model.client.indices
    end
  end
end