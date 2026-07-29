module RedmineResources
  module Charts
    module Components
      class BaseCard < BaseComponent
        DESCRIPTION_LINE_HEIGHT = 1.25 # em
        CARD_HEIGHT_COEFFICIENT = 2 * DESCRIPTION_LINE_HEIGHT # em

        def initialize(date, issue, project, resource_booking, time_entries)
          @date = date
          @issue = issue
          @project = project
          @resource_booking = resource_booking
          @time_entries = time_entries

          @spent_hours = @time_entries.sum(&:hours)
          @description = @issue ? @issue.subject : @project.name
        end

        protected

        def project_heading
          link_to l(:label_project), project_path(@project), class: 'icon icon-project'
        end

        def issue_heading
          h("#{@issue.tracker} ") + link_to_issue(@issue, subject: false, tracker: false)
        end

        def render_card_heading
          @issue ? issue_heading : project_heading
        end
      end
    end
  end
end
