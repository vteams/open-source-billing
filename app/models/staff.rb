class Staff < ActiveRecord::Base
  include DateFormats
  include StaffSearch if OSB::CONFIG::ENABLE_SEARCH
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
    # get the company
    company_id = params['current_company'] || params[:user].current_company || params[:user].current_account.companies.first.id
    company =  Company.find_by(id: company_id)

    # get the staffs associated with companies
    company_staffs = company.staffs
    company_staffs = company_staffs.search(params[:search]).records if params[:search].present? and company_staffs.present?
    company_staffs = company_staffs.send(params[:status])

    # get the account
    account = params[:user].current_account

    # get the staffs associated with accounts
    account_staffs = account.staffs
    account_staffs = account_staffs.search(params[:search]).records if params[:search].present? and account_staffs.present?
    account_staffs = account_staffs.send(params[:status])

    # get the unique clients associated with companies and accounts
    staffs = ( account_staffs + company_staffs).uniq

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

  def image_name
    name.first.camelize
  end

  def group_date
    created_at.strftime("%d/%m/%Y")
  end
end
