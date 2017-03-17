module Reporting
  module TaxActivity
    def self.get_recent_activity(page,per_page,sort_column,sort_direction)
      mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
      recent_activity = {}

      options[:status] = 'unarchived'
      method = mappings[options[:status].to_sym]
      active_items = Tax.send(method).page(page).per(per_page).order(sort_column + " " + sort_direction)
      options[:status] = 'only_deleted'
      method = mappings[options[:status].to_sym]
      deleted_items = Tax.send(method).page(page).per(per_page).order(sort_column + " " + sort_direction)
      options[:status] = 'archived'
      method = mappings[options[:status].to_sym]
      archived_items =Tax.send(method).page(page).per(per_page).order(sort_column + " " + sort_direction)
      active_items_progress = {}
      active_items.group_by{|i| i.group_date}.each do |date, items|
        active_items_progress[date] = items.collect(&:percentage).sum rescue 0
      end

      deleted_items_progress = {}
      deleted_items.group_by{|i| i.group_date}.each do |date, items|

        deleted_items_progress[date] = items.collect(&:item_total).sum rescue 0
      end

      archived_items_progress = {}
      archived_items.group_by{|i| i.group_date}.each do |date, items|

        archived_items_progress[date] = items.collect(&:item_total).sum rescue 0
      end



      recent_activity.merge!(active_items_total: active_items.reject{|x| x.item_total.nil?}.collect(&:item_total).sum)
      recent_activity.merge!(deleted_items_total: deleted_items.reject{|x| x.item_total.nil?}.collect(&:item_total).sum)
      recent_activity.merge!(archived_items_total: archived_items.reject{|x| x.item_total.nil?}.collect(&:item_total).sum)
      recent_activity.merge!(active_items_progress: active_items_progress)
      recent_activity.merge!(deleted_items_progress: deleted_items_progress)
      recent_activity.merge!(archived_items_progress: archived_items_progress)

      recent_activity
    end
  end
end