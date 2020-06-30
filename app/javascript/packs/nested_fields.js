(function($) {
    window.NestedFormEvents = function() {
        this.addFields = $.proxy(this.addFields, this);
        this.removeFields = $.proxy(this.removeFields, this);
    };

    NestedFormEvents.prototype = {
        addFields: function(e) {
            initSelectActionLink();
            var link      = e.currentTarget;

            $("select.items_list:last, select.tax1, select.tax2, select.tasks_list:last, select.members_list:last").select2({
                minimumResultsForSearch: -1,
                dropdownCssClass: "tax-dropdown"
            });
            if ($('.project-form-inline').length > 0){
                var id = $('#staff_container').find('.nested-fields').length;
                var element = $('#staff_container').find('.nested-fields:last');
                $(element).find('.filled-in').attr('id', 'project_staff_' + id);
                $(element).find('.staff-label').attr('for', 'project_staff_' + id);
                Project.change_project_task();
                Project.change_project_staff();
                Project.enable_staff_fields();
                Project.toggleStaffRemoveButton();
            }
            if ($('.invoice-form').length > 0) {
                Invoice.change_invoice_item();
                Invoice.changeTax();
                OsbPlugins.load_functions();
            } else {
                Estimate.change_estimate_item();
                Estimate.changeTax();
                OsbPlugins.estimate_load_functions();
            }
            return false;
        },
        newId: function() {
            return new Date().getTime();
        }
    };

    window.nestedFormEvents = new NestedFormEvents();
    $(document).ready(function() {
      $('.nested-forms').on('cocoon:after-insert', nestedFormEvents.addFields);
    });
})(jQuery);

// http://plugins.jquery.com/project/closestChild
/*
 * Copyright 2011, Tobias Lindig
 *
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 */
(function($) {
    $.fn.closestChild = function(selector) {
        // breadth first search for the first matched node
        if (selector && selector != '') {
            var queue = [];
            queue.push(this);
            while(queue.length > 0) {
                var node = queue.shift();
                var children = node.children();
                for(var i = 0; i < children.length; ++i) {
                    var child = $(children[i]);
                    if (child.is(selector)) {
                        return child; //well, we found one
                    }
                    queue.push(child);
                }
            }
        }
        return $();//nothing found
    };
})(jQuery);
