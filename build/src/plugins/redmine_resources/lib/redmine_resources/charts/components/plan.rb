module RedmineResources
  module Charts
    module Components
      class Plan < BaseComponent
        attr_reader :date_title, :today_css_class, :week_day_css_class,
                    :workload_card, :booked_cards, :unbooked_cards, :allocated_hours

        def initialize(date, is_workday, resource_bookings, time_entries)
          @date = date
          @date_title = I18n.l(@date, format: '%a, %d')
          @today_css_class = 'today' if @date == User.current.today

          @is_workday = is_workday
          @week_day_css_class = 'week-end' unless @is_workday

          @resource_bookings = resource_bookings
          @time_entries = time_entries
          @booked_time_entries = find_booked_time_entries(@resource_bookings, @time_entries)
          @unbooked_time_entries = @time_entries - @booked_time_entries
          @allocated_hours = @resource_bookings.sum(&:hours_per_day)

          @workload_card = WorkloadCard.new(@is_workday, @resource_bookings, @time_entries)
          @booked_cards = build_booked_cards(@date, @is_workday, @resource_bookings, @booked_time_entries)
          @unbooked_cards = build_unbooked_cards(@date, @unbooked_time_entries)
        end

        private

        def build_booked_cards(date, is_workday, resource_bookings, time_entries)
          time_entries_by_project_and_issue = time_entries.group_by do |time_entry|
            key_by(time_entry.project, time_entry.issue)
          end

          resource_bookings.inject([]) do |booked_cards, resource_booking|
            issue = resource_booking.issue
            project = resource_booking.project
            time_entries = time_entries_by_project_and_issue[key_by(project, issue)] || []

            if is_workday || time_entries.present?
              booked_cards << Components::BookedCard.new(date, issue, project, resource_booking, time_entries)
            end

            booked_cards
          end
        end

        def build_unbooked_cards(date, time_entries)
          time_entries_by_project_and_issue = time_entries.group_by do |time_entry|
            key_by(time_entry.project, time_entry.issue)
          end

          time_entries_by_project_and_issue.inject([]) do |unbooked_cards, (key, time_entries)|
            issue = time_entries.first.issue
            project = time_entries.first.project
            unbooked_cards << Components::UnbookedCard.new(date, issue, project, time_entries)
            unbooked_cards
          end
        end

        def find_booked_time_entries(resource_bookings, time_entries)
          booked_issue_ids = resource_bookings.map(&:issue_id).compact
          booked_project_ids = resource_bookings.select { |rb| rb.issue.blank? }.map(&:project_id)
          time_entries.select do |time_entry|
            if time_entry.issue_id
              booked_issue_ids.include?(time_entry.issue_id)
            else
              booked_project_ids.include?(time_entry.project_id)
            end
          end
        end

        def key_by(project, issue)
          "#{project.id}-#{issue.try(:id)}"
        end
      end
    end
  end
end
