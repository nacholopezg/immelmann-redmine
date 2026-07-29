module RedmineResources
  module Charts
    module Components
      class UnbookedCard < BaseCard
        def initialize(date, issue, project, time_entries)
          super(date, issue, project, nil, time_entries)

          @description_box_height = CARD_HEIGHT_COEFFICIENT * [[@spent_hours, 1].max, 24].min
        end

        def render
          <<-HTML.html_safe
            <div class="booking-card #{'ending' if @issue && @issue.due_date == @date} spent">
              <p class="project-name" style="display: block;">#{@project}</p>
              <div class="issue-id tooltip">
                <span class="tip issue-spent">
                  #{render_time_entries_tooltip(@time_entries.sort { |a, b| b.updated_on <=> a.updated_on })}
                  #{'<br />' + show_more_time_entries_link(@date, @project, @issue) if @time_entries.size > 2}
                </span>
                <strong class="icon icon-time">#{render_card_heading}</strong>
                <span class="hours">#{l(:label_resources_f_hour_short, value: to_int_if_whole(@spent_hours))}</span>
              </div>
              <div class="description-box" style="height: #{@description_box_height}em;">
                <div class="text-box">
                  #{@description}
                </div>
              </div>
            </div>
          HTML
        end
      end
    end
  end
end
