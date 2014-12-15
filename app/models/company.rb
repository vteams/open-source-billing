class Company < ActiveRecord::Base
  #scope :multiple, lambda { |ids_list| where("id in (?)", ids_list) }
  #attr_accessible :account_id, :city, :company_name, :company_tag_line, :contact_name, :contact_title, :country, :email, :fax_number, :logo, :memo, :phone_number, :postal_or_zipcode, :province_or_state, :street_address_1, :street_address_2
  scope :multiple, lambda { |ids_list| where("id in (?)", ids_list.is_a?(String) ? ids_list.split(',') : [*ids_list]) }

  mount_uploader :logo, ImageUploader

  has_many :company_entities, :as => :parent
  has_many :items, :through => :company_entities, :source => :entity, :source_type => 'Item'
  has_many :clients, :through => :company_entities, :source => :entity, :source_type => 'Client'
  has_many :company_email_templates, :as => :parent
  has_many :email_templates, :through => :company_email_templates, :foreign_key => 'template_id'
  has_many :invoices
  has_many :payments
  has_many :sent_emails
  belongs_to :account

  # archive and delete
  acts_as_archival
  acts_as_paranoid

  # filter companies i.e active, archive, deleted
  def self.filter(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    params[:account].companies.send(method).page(params[:page]).per(params[:per])
  end

  def self.recover_archived(ids)
    multiple(ids).map(&:unarchive)
  end

  def self.recover_deleted(ids)
    multiple(ids).only_deleted.each { |company| company.recover; company.unarchive }
  end

end
