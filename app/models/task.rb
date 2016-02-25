class Task < ActiveRecord::Base
  include DateFormats
  paginates_per 10

  acts_as_archival
  acts_as_paranoid

  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }

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

end
