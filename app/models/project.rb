class Project < ActiveRecord::Base

  belongs_to :client
  belongs_to :company


  validates :project_name, presence: true
  validates :client_id, presence: true
  validates :manager_id, presence: true

  acts_as_archival
  acts_as_paranoid

  def self.filter(params, per_page)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[:active]
    self.send(method).page(params[:page]).per(per_page)
  end

end
