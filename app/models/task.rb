class Task < ActiveRecord::Base
  include DateFormats
  include TaskSearch
  paginates_per 10

  acts_as_archival
  acts_as_paranoid

  has_many :project_tasks

  belongs_to :company
  has_many :company_entities, :as => :entity
  has_many :logs, dependent: :destroy

  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }
  scope :archive_multiple, lambda { |ids| multiple(ids).map(&:archive) }
  scope :delete_multiple, lambda { |ids| multiple(ids).map(&:destroy) }
  scope :rate, -> (rate) { where(rate: rate) }
  scope :created_at, -> (created_at) { where(created_at: created_at) }


  # filter tasks i.e active, archive, deleted
  def self.filter(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    Task.send(method).page(params[:page]).per(params[:per])
  end

  def self.recover_archived(ids)
    multiple(ids).map(&:unarchive)
  end

  def self.recover_deleted(ids)
    multiple(ids).only_deleted.each { |task| task.restore; task.unarchive }
  end

  def self.unassigned
    where(project_id: nil)
  end

  def self.is_exists? task_name, association = nil
    association.present? ? association.tasks.where(:name => task_name).present? : where(:name => task_name).present?
  end


  def self.get_tasks(params)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    user = User.current
    date_format = user.nil? ? '%Y-%m-%d' : (user.settings.date_format || '%Y-%m-%d')
    # get the company
    company_id = params['current_company'] || params[:user].current_company || params[:user].current_account.companies.first.id
    company =  Company.find_by(id: company_id)

    # get the tasks associated with companies
    company_tasks = company.tasks
    company_tasks = company_tasks.search(params[:search]).records if params[:search].present? and company_tasks.present?
    company_tasks = company_tasks.send(mappings[params[:status].to_sym]) if params[:status].present?
    company_tasks = company_tasks.rate((params[:min_rate].to_i .. params[:max_rate].to_i)) if params[:min_rate].present?
    company_tasks = company_tasks.created_at(
        (Date.strptime(params[:create_at_start_date], date_format) .. Date.strptime(params[:create_at_end_date], date_format))
    ) if params[:create_at_start_date].present?

    # get the account
    account = params[:user].current_account

    # get the tasks associated with accounts
    account_tasks = account.tasks
    account_tasks = account_tasks.search(params[:search]).records if params[:search].present? and account_tasks.present?
    account_tasks = account_tasks.send(mappings[params[:status].to_sym]) if params[:status].present?
    account_tasks = account_tasks.rate((params[:min_rate].to_i .. params[:max_rate].to_i)) if params[:min_rate].present?
    account_tasks = account_tasks.created_at(
        (Date.strptime(params[:create_at_start_date], date_format) .. Date.strptime(params[:create_at_end_date], date_format))
    ) if params[:create_at_start_date].present?

    # get the unique clients associated with companies and accounts
    tasks = ( account_tasks + company_tasks).uniq

    # sort tasks in ascending or descending order
    tasks = tasks.sort do |a, b|
      b, a = a, b if params[:sort_direction] == 'desc'

      if a.send(params[:sort_column]).class.to_s == 'BigDecimal' and b.send(params[:sort_column]).class.to_s == 'BigDecimal'
        a.send(params[:sort_column]).to_i <=> b.send(params[:sort_column]).to_i
      else
        a.send(params[:sort_column]).to_s <=> b.send(params[:sort_column]).to_s
      end
    end if params[:sort_column] && params[:sort_direction]

    Kaminari.paginate_array(tasks).page(params[:page]).per(params[:per])

  end

  def image_name
    name.first.camelize
  end

  def group_date
    created_at.strftime('%B %Y')
  end

end
