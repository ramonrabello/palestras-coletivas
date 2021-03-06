class EnrollmentDecorator
  OPTIONS = [
    active: {event: :enrollment_events, user: :registered_users},
    present: {event: :participation_events, user: :present_users}
  ]

  def initialize(enrollment, option_type, params = nil)
    @enrollment = enrollment
    @option_type = option_type
    @params = params
  end

  def create
    @enrollment.save && update_counter_of_events_and_users
  end

  def update
    @enrollment.update_attributes(@params) && update_counter_of_events_and_users
  end

private

  def update_counter_of_events_and_users
    condition = @option_type == 'active' ? @enrollment.active? : @enrollment.present?
    operation = condition ? :inc : :dec

    @enrollment.user.set_counter(OPTIONS[0][@option_type.to_sym][:event], operation)
    @enrollment.event.set_counter(OPTIONS[0][@option_type.to_sym][:user], operation)

    true
  end
end