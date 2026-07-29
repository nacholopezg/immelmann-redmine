module RedmineResources
  module Charts
    class MyResourceBookingsChart < Components::BaseComponent
      attr_reader :plans

      def initialize(user, options = {})
        @user = user

        @today = @user.today
        @date_from = RedmineResources.beginning_of_week(@user)
        @date_to = @date_from.next_day(6)

        @resource_bookings = ResourceBooking.includes(:project, :issue).between(@date_from, @date_to).where(assigned_to: @user).to_a
        @time_entries = TimeEntry.includes(:project, :issue, :activity).where('spent_on BETWEEN ? AND ?', @date_from, @date_to).where(user: @user).to_a

        @plans = build_plans(@date_from, @date_to, @resource_bookings, @time_entries)

        @capacity_hours = RedmineResources.default_workday_length * working_days(@date_from, @date_to)
        @allocated_hours = @plans.sum(&:allocated_hours)
        @spent_hours = @time_entries.sum(&:hours)
      end

      def render_summary
        @summary ||=
          "(#{l(:label_resources_capacity)}: #{l(:label_f_hour_short, value: '%0.2f' % @capacity_hours)}, " +
            "#{l(:label_resources_allocated)}: #{l(:label_f_hour_short, value: '%0.2f' % @allocated_hours)}, " +
            " #{l(:label_resources_spent)}: #{l(:label_f_hour_short, value: '%0.2f' % @spent_hours)})"
      end

      def title_url_options
        {
          controller: 'resource_bookings',
          action: 'index',
          set_filter: 1,
          f: [:assigned_to_id],
          op: { assigned_to_id: '=' },
          v: { assigned_to_id: [@user.id] },
          months: 1,
          date_from: @date_from
        }
      end

      def empty?
        @resource_bookings.empty? && @time_entries.empty?
      end

      private

      def build_plans(date_from, date_to, resource_bookings, time_entries)
        (date_from..date_to).inject([]) do |plans, day|
          resource_bookings_by_day = resource_bookings.select { |rb| rb.interval.cover?(day) }
          time_entries_by_day = time_entries.select { |time_entry| time_entry.spent_on == day }
          plans << Components::Plan.new(day, non_working_week_days.exclude?(day.cwday), resource_bookings_by_day, time_entries_by_day)
          plans
        end
      end
    end
  end
end
