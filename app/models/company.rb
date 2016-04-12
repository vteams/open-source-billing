class Company < ActiveRecord::Base

  scope :multiple, lambda { |ids_list| where("id in (?)", ids_list.is_a?(String) ? ids_list.split(',') : [*ids_list]) }

  mount_uploader :logo, ImageUploader
  skip_callback :commit, :after, :remove_logo!

  has_many :company_entities, :as => :parent
  has_many :items, :through => :company_entities, :source => :entity, :source_type => 'Item'
  has_many :tasks, :through => :company_entities, :source => :entity, :source_type => 'Task'
  has_many :staffs, :through => :company_entities, :source => :entity, :source_type => 'Staff'
  has_many :clients, :through => :company_entities, :source => :entity, :source_type => 'Client'
  has_many :company_email_templates, :as => :parent
  has_many :email_templates, :through => :company_email_templates, :foreign_key => 'template_id'
  has_many :invoices
  has_many :estimates
  has_many :expenses
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
    multiple(ids).only_deleted.each { |company| company.restore; company.unarchive }
  end

end
