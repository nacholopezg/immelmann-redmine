class ResourceBookingsMailer < Mailer
  SENDING_METHOD = (Redmine::VERSION.to_s < '4.0' ? 'deliver' : 'deliver_later').freeze

  def resource_booking_create(user, resource_booking)
    prepare_variables(resource_booking)
    mail to: user, subject: l(:label_resource_booking_added)
  end

  def self.deliver_resource_booking_create(resource_booking)
    resource_booking.email_users.each do |user|
      resource_booking_create(user, resource_booking).send(SENDING_METHOD)
    end
  end

  def resource_booking_update(user, resource_booking)
    prepare_variables(resource_booking)
    mail to: user, subject: l(:label_resource_booking_updated)
  end

  def self.deliver_resource_booking_update(resource_booking)
    resource_booking.email_users.each do |user|
      resource_booking_update(user, resource_booking).send(SENDING_METHOD)
    end
  end

  private

  def prepare_variables(resource_booking)
    @resource_booking = resource_booking
    @project = resource_booking.project
    @issue = resource_booking.issue
    if @issue.present?
      @issue_url = url_for(controller: 'issues', action: 'show', id: @issue)
    else
      @project_url = url_for(controller: 'projects', action: 'show', id: @project)
    end
    @author = @resource_booking.author
  end
end
