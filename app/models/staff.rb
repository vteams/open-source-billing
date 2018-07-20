class Staff < ActiveRecord::Base
  include DateFormats
  include StaffSearch
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
  scope :rate, -> (rate) { where(rate: rate) }
  scope :created_at, -> (created_at) { where(created_at: created_at) }

  # filter staffs i.e active, archive, deleted
  def self.filter(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    user = User.current
    date_format = user.nil? ? '%Y-%m-%d' : (user.settings.date_format || '%Y-%m-%d')

    staffs = self
    staffs = staffs.rate((params[:min_rate].to_i .. params[:max_rate].to_i)) if params[:min_rate].present?
    staffs = staffs.created_at(
        (Date.strptime(params[:create_at_start_date], date_format) .. Date.strptime(params[:create_at_end_date], date_format))
    ) if params[:create_at_start_date].present?
    staffs = staffs.send(mappings[params[:status].to_sym]) if params[:status].present?

    staffs
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
    company_staffs = company_staffs.filter(params) if company_staffs.present?

    # get the account
    account = params[:user].current_account

    # get the staffs associated with accounts
    account_staffs = account.staffs
    account_staffs = account_staffs.search(params[:search]).records if params[:search].present? and account_staffs.present?
    account_staffs = account_staffs.filter(params) if account_staffs.present?

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
    created_at.strftime('%B %Y')
  end
end
