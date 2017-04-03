class Staff < ActiveRecord::Base
  include DateFormats
  paginates_per 10

  acts_as_archival
  acts_as_paranoid

  belongs_to :company
  belongs_to :user
  has_many :company_entities, :as => :entity
  has_many :team_members
  has_many :projects , through: :team_members

  accepts_nested_attributes_for :user, :allow_destroy => true

  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }
  scope :archive_multiple, lambda { |ids| multiple(ids).map(&:archive) }
  scope :delete_multiple, lambda { |ids| multiple(ids).map(&:destroy) }

  # filter staffs i.e active, archive, deleted
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

  def self.get_staffs(params)
    account = params[:user].current_account

    # get the staffs associated with companies
    company_id = params['current_company'] || params[:user].current_company || params[:user].current_account.companies.first.id
    company_staffs = Company.find(company_id).staffs.send(params[:status])

    # get the unique staffs associated with companies and accounts
    staffs = (account.staffs.send(params[:status]) + company_staffs).uniq

    # sort staffs in ascending or descending order
    staffs.sort! do |a, b|
      b, a = a, b if params[:sort_direction] == 'desc'

      if a.send(params[:sort_column]).class.to_s == 'BigDecimal' and b.send(params[:sort_column]).class.to_s == 'BigDecimal'
        a.send(params[:sort_column]).to_i <=> b.send(params[:sort_column]).to_i
      else
        a.send(params[:sort_column]).to_s <=> b.send(params[:sort_column]).to_s
      end
    end if params[:sort_column] && params[:sort_direction]

    Kaminari.paginate_array(staffs).page(params[:page]).per(params[:per])

  end
end
