[1mdiff --git a/app/models/log.rb b/app/models/log.rb[m
[1mindex 4163692..7dacf6c 100644[m
[1m--- a/app/models/log.rb[m
[1m+++ b/app/models/log.rb[m
[36m@@ -5,4 +5,9 @@[m [mclass Log < ActiveRecord::Base[m
 [m
   validates :project_id,:task_id,:date , presence: true[m
 [m
[32m+[m
[32m+[m[32m  def line_total[m
[32m+[m[32m    (hours * task.rate).round(2)[m
[32m+[m[32m  end[m
[32m+[m
 end[m
[1mdiff --git a/app/views/logs/_form_invoice.html.erb b/app/views/logs/_form_invoice.html.erb[m
[1mindex 27785f6..0e67f26 100644[m
[1m--- a/app/views/logs/_form_invoice.html.erb[m
[1m+++ b/app/views/logs/_form_invoice.html.erb[m
[36m@@ -108,7 +108,7 @@[m
                     <td class="align_center"><%= log.task.description %></td>[m
                     <td class="align_center"><%= log.task.rate %></td>[m
                     <td class="align_center"><%= log.hours %></td>[m
[31m-                    <td class="align_center line_total"><%= log.hours * log.task.rate %></td>[m
[32m+[m[32m                    <td class="align_center line_total"><%= log.line_total %></td>[m
                 </tr>[m
 [m
             <% end %>[m
