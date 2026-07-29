module RedmineResources
  module Charts
    module Components
      class WorkloadCard < BaseComponent
        def initialize(is_workday, resource_bookings, time_entries)
          @is_workday = is_workday
          @resource_bookings = resource_bookings
          @time_entries = time_entries

          @planned_hours = to_int_if_whole(@resource_bookings.sum(&:hours_per_day))
          @workday_length = to_int_if_whole(RedmineResources.default_workday_length)
          @spent_hours = to_int_if_whole(@time_entries.sum(&:hours))
        end

        def render
          if @is_workday || @spent_hours > 0
            <<-HTLM.html_safe
              <div class="workload-card #{color_css_class}">
                 <div class="spent spent-time" style="display: block;">
                   #{l(:label_resources_f_hour_short, value: @spent_hours)}
                 </div>
                 #{render_planned_hours_and_workday_length_ratio if @is_workday}
              </div>
            HTLM
          end
        end

        private

        def render_planned_hours_and_workday_length_ratio
          "<p>#{@planned_hours}/#{@workday_length}</p>"
        end

        def color_css_class
          if !@is_workday
            'gray'
          elsif @planned_hours == @workday_length
            'full'
          elsif @planned_hours > @workday_length
            'red'
          else
            'green'
          end
        end
      end
    end
  end
end
