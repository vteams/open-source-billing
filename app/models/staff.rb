class Staff < ActiveRecord::Base
  include DateFormats
  paginates_per 10

  acts_as_archival
  acts_as_paranoid

  belongs_to :company
  has_many :company_entities, :as => :entity
  has_many :team_members

  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }
  scope :archive_multiple, lambda { |ids| multiple(ids).map(&:archive) }
  scope :delete_multiple, lambda { |ids| multiple(ids).map(&:destroy) }

  # filter tasks i.e active, archive, deleted
  def self.filter(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    Staff.send(method).page(params[:page]).per(params[:per])
  end

  def self.recover_archived(ids)
    multiple(ids).map(&:unarchive)
  end

  def self.recover_deleted(ids)
    multiple(ids).only_deleted.each { |staff| staff.restore; staff.unarchive }
  end

  def self.is_exists? staff_eamil, company_id = nil
    company = Company.find company_id if company_id.present?
    company.present? ? company.staffs.where(:email => staff_eamil).present? : where(:email => staff_eamil).present?
  end

end
