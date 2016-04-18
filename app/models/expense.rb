class Expense < ActiveRecord::Base
  include DateFormats
  belongs_to :client
  belongs_to :category, class_name: 'ExpenseCategory', foreign_key: 'category_id'
  belongs_to :tax1, :foreign_key => 'tax_1', :class_name => 'Tax'
  belongs_to :tax2, :foreign_key => 'tax_2', :class_name => 'Tax'
  belongs_to :company

  paginates_per 10

  acts_as_archival
  acts_as_paranoid

  #scopes
  scope :multiple, lambda { |ids| where('id IN(?)', ids.is_a?(String) ? ids.split(',') : [*ids]) }

  # filter companies i.e active, archive, deleted
  def self.filter(params, per_page)
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]
    Expense.send(method).page(params[:page]).per(params[:per_page])
  end

  def self.recover_archived(ids)
    multiple(ids).map(&:unarchive)
  end

  def self.recover_deleted(ids)
    multiple(ids).only_deleted.each { |expense| expense.restore; expense.unarchive }
  end

  def total
    amount + total_tax_amount
  end

  def total_tax_amount
    tax1_amount + tax2_amount
  end

  def tax1_amount
    tax1.present? ? amount * (tax1.percentage / 100.0) : 0.0
  end

  def tax2_amount
    tax2.present? ? amount * (tax2.percentage / 100.0) : 0.0
  end

end
