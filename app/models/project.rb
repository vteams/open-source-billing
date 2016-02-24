class Project < ActiveRecord::Base

  belongs_to :client
  belongs_to :company


  acts_as_archival
  acts_as_paranoid

  def self.filter(params, per_page)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[:active]
    self.send(method).page(params[:page]).per(per_page)
  end

end
