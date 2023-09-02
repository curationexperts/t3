# Various helpers for User dashboard views
module UserHelper
  # Human friendly formatter for login dates
  def last_login(user)
    timestamp = user.current_sign_in_at
    duration(timestamp)
  end

  # Human friendly formatter for Time-compatible values
  def duration(timestamp)
    return tag.span('never', class: 'login_timestamp empty') unless timestamp

    suffix = timestamp.future? ? ' from now' : ' ago'
    duration_text = time_ago_in_words(timestamp) + suffix
    tag.span(duration_text, class: 'login_timestamp', datetime: timestamp.iso8601)
  rescue StandardError
    tag.span('n/a', class: 'login_timestamp empty')
  end

  # User account status:
  #   invited  - invitation e-mail sent to user, but not accepted
  #   active   - invitation accepted and user has logged in
  #   inactive - user has not logged in for over a year
  #   unknown  - any other state
  def status_badge(user) # rubocop:disable Metrics/MethodLength
    return unless user.is_a?(User)

    state = if user.invited_to_sign_up?
              :invited
            elsif user.sign_in_count.positive? && user.current_sign_in_at >= 1.year.ago
              :active
            elsif user.sign_in_count.positive? && user.current_sign_in_at < 1.year.ago
              :inactive
            else
              :unknown
            end

    tag.span(state, class: "user_state #{state}")
  end
end
