#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
module Services
  class ProjectBulkActionsService
    attr_reader :projects, :project_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted destroy_archived)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @project_ids = @options[:project_ids]
      @projects = ::Project.multiple(@project_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform).call.merge({project_ids: @project_ids, action_to_perform: @action_to_perform})
    end

    def archive
      @projects.map(&:archive)
      {action: 'archived', projects: get_projects('unarchived')}
    end

    def destroy
      (@projects).map(&:destroy)
      {action: 'deleted', projects: get_projects('unarchived')}
    end

    def destroy_archived
      (@projects).map(&:destroy)
      {action: 'deleted from archived', projects: get_projects('archived')}
    end

    def recover_archived
      @projects.map(&:unarchive)
      {action: 'recovered from archived', projects: get_projects('archived')}
    end

    def recover_deleted
      @projects.only_deleted.map { |project| project.restore; project.unarchive;}
      projects = ::Project.only_deleted.page(@options[:page]).per(@options[:per])
      {action: 'recovered from deleted', projects: get_projects('only_deleted')}
    end

    private

    def get_projects(project_filter)
      ::Project.joins("LEFT OUTER JOIN clients ON clients.id = projects.client_id ").send(project_filter).page(@options[:page]).per(@options[:per])
    end
  end
end
