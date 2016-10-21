class Project < ActiveRecord::Base
  include ::OSB
  include DateFormats
  include Trackstamps

  scope :multiple, ->(ids_list) {where("id in (?)", ids_list.is_a?(String) ? ids_list.split(',') : [*ids_list]) }

  belongs_to :client
  belongs_to :manager, class_name: 'TeamMember', foreign_key: 'manager_id'
  belongs_to :company
  belongs_to :user
  has_many :project_tasks, dependent: :destroy
  has_many :logs, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :staffs, through: :team_members
  has_many :logs, dependent: :destroy
  has_many :invoices, dependent: :destroy

  accepts_nested_attributes_for :project_tasks , :reject_if => proc { |task| task['task_id'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :team_members ,  :reject_if => proc { |staff| staff['staff_id'].blank? }, :allow_destroy => true

  acts_as_archival
  acts_as_paranoid

  before_save :check_estimate_hours

  def check_estimate_hours
    self.total_hours = self.total_hours.present? ? self.total_hours : 0.0
  end

  def self.filter(params, per_page)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    self.send(method).page(params[:page]).per(per_page)
  end

  def self.multiple_projects ids
    ids = ids.split(',') if ids and ids.class == String
    where('id IN(?)', ids)
  end


  def self.recover_archived ids
    self.multiple_projects(ids).each { |project| project.unarchive }
  end

  def self.recover_deleted ids
    multiple_projects(ids).only_deleted.each do |project|
      project.restore
      project.unarchive
    end
  end

  def unscoped_client
    Client.unscoped.find_by_id self.client_id
  end

end
