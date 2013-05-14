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
module ApplicationHelper
  # to add a active class to current link on main menu
  def nav_link(text, link)
    recognized = Rails.application.routes.recognize_path(link)
    if recognized[:controller] == params[:controller] && recognized[:action] == params[:action]
      content_tag(:li, :class => "active") do
        link_to(text, link)
      end
    else
      content_tag(:li) do
        link_to(text, link)
      end
    end
  end

  def custom_per_page
    content_tag(:select,
                options_for_select([10, 5, 20, 50, 100], session["#{controller_name}-per_page"]),
                :data => {
                    :remote => true,
                    :url => url_for(:action => action_name, :params => params.except(:page), :flag => "per_page")},
                :name => "per",
                :class => "per_page"
    )
  end

  # helper function make a link to submit its parent form
  def link_to_submit(*args, &block)
    link_to_function (block_given? ? capture(&block) : args[0]), "jQuery(this).closest('form').submit();", args.extract_options!
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => 1), {:class => "#{css_class} sortable", :remote => true}
  end

end