module RedmineResources
  module Charts
    module Components
      class BookedCard < BaseCard
        def initialize(date, issue, project, resource_booking, time_entries)
          super

          @planned_hours = @resource_booking.hours_per_day
          @progress_bar = BookedCardProgressBar.new(@date, @issue, @project, @spent_hours, @planned_hours)
          @description_box_height = CARD_HEIGHT_COEFFICIENT * [@planned_hours, 24].min
        end

        def render
          <<-HTML.html_safe
            <div class="booking-card #{'ending' if @issue && @issue.due_date == @date} booking">
              <p class="project-name" style="display: block;">#{@project}</p>
              <div class="issue-id tooltip">
                <span class="tip issue-spent">
                  #{render_resource_booking_tooltip(@resource_booking)}
                </span>
                <strong>#{render_card_heading}</strong>
                <span class="hours">#{l(:label_resources_f_hour_short, value: to_int_if_whole(@planned_hours))}</span>
              </div>
              <div class="description-box" style="height: #{@description_box_height}em;">
                <div class="text-box">
                  #{@description}
                </div>
              </div>
              #{@progress_bar.render}
            </div>
          HTML
        end
      end
    end
  end
end
