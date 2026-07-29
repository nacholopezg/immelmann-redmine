module RedmineChecklists
  module Patches
    module IssuesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method :details_to_strings_without_checklists, :details_to_strings
          alias_method :details_to_strings, :details_to_strings_with_checklists
          if Redmine::VERSION.to_s >= '2.2' && Redmine::VERSION.to_s <= '2.4'
            alias_method :render_email_issue_attributes_without_checklists, :render_email_issue_attributes
            alias_method :render_email_issue_attributes, :render_email_issue_attributes_with_checklists
          end
        end
      end


      module InstanceMethods

        def render_email_issue_attributes_with_checklists(issue, html = false)
          journal = issue.journals.order(:id).last
          return render_email_issue_attributes_without_checklists(issue, html) unless journal
          details = journal.details
          return render_email_issue_attributes_without_checklists(issue, html) unless details
          checklist_details = details.select{ |x| x.prop_key == 'checklist'}
          return render_email_issue_attributes_without_checklists(issue, html) unless checklist_details.any?
          return render_email_issue_attributes_without_checklists(issue, html) + details_to_strings_with_checklists(checklist_details, !html).join(html ? "<br/>".html_safe : "\n")
        end

        def details_to_strings_with_checklists(details, no_html = false, options = {})
          details_checklist, details_other = details.partition{ |x| x.prop_key == 'checklist' }
          details_checklist.map do |detail|
            result = []
            diff = Hash.new([])

            if Checklist.old_format?(detail)
              result << "<b>#{l(:label_checklist_item)}</b> #{l(:label_checklist_changed_from)} #{detail.old_value} #{l(:label_checklist_changed_to)} #{detail.value}"
            else
              diff = JournalChecklistHistory.new(detail.old_value, detail.value).diff
            end

            checklist_item_label = lambda do |item|
              item[:is_section] ? l(:label_checklist_section) : l(:label_checklist_item)
            end

            # <PRO>
            if diff[:removed].any?
              diff[:removed].each do |item|
                result << "<b>#{ERB::Util.h checklist_item_label[item]}</b> #{ERB::Util.h l(:label_checklist_deleted)} (<strike><i>#{ERB::Util.h item[:subject]}</i></strike>)"
              end
            end

            if diff[:renamed].any?
              diff[:renamed].each do |was, became|
                result << "<b>#{ERB::Util.h checklist_item_label[was]}</b> #{ERB::Util.h l(:label_checklist_changed_from)}" +
                            " <i>#{ERB::Util.h was.subject}</i> #{ERB::Util.h l(:label_checklist_changed_to)} <i>#{ERB::Util.h  became.subject}</i>"
              end
            end

            if diff[:added].any?
              diff[:added].each do |item|
                s = "<b>#{ERB::Util.h checklist_item_label[item]}</b>"
                s << " <input type='checkbox' #{item.is_done ? 'checked' : '' } disabled>" unless item.is_section
                result << s + " <i>#{ERB::Util.h item[:subject]}</i> #{ERB::Util.h l(:label_checklist_added)}"
              end
            end
             # </PRO>

            if diff[:done].any?
              diff[:done].each do |item|
                result << "<b>#{ERB::Util.h l(:label_checklist_item)}</b> <input type='checkbox' #{item.is_done ? 'checked' : '' } disabled> <i>#{ERB::Util.h item[:subject]}</i> #{ERB::Util.h l(:label_checklist_done)}"
              end
            end

            if diff[:undone].any?
              diff[:undone].each do |item|
                result << "<b>#{ERB::Util.h l(:label_checklist_item)}</b> <input type='checkbox' #{item.is_done ? 'checked' : '' } disabled> <i>#{ERB::Util.h item[:subject]}</i> #{ERB::Util.h l(:label_checklist_undone)}"
              end
            end

            result = result.join('</li><li>').html_safe
            result = nil if result.blank?
            if result && no_html
              result = result.gsub /<\/li><li>/, "\n"
              result = result.gsub /<input type='checkbox'[^c^>]*checked[^>]*>/, '[x]'
              result = result.gsub /<input type='checkbox'[^c^>]*>/, '[ ]'
              result = result.gsub /<[^>]*>/, ''
              result = CGI.unescapeHTML(result)
            end
            result
          end.compact + details_to_strings_without_checklists(details_other, no_html, options)
        end
      end
    end
  end
end

unless IssuesHelper.included_modules.include?(RedmineChecklists::Patches::IssuesHelperPatch)
  IssuesHelper.send(:include, RedmineChecklists::Patches::IssuesHelperPatch)
end
