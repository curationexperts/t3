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
    return tag.span('n/a', class: 'login_timestamp empty') unless timestamp.try(:to_time)

    tag.span(duration_text(timestamp), class: 'login_timestamp', datetime: timestamp.iso8601)
  end

  def duration_text(timestamp)
    suffix = timestamp.future? ? ' from now' : ' ago'
    time_ago_in_words(timestamp) + suffix
  end

  def status_badge(user)
    return unless user.is_a?(User)

    state = account_state(user)
    tag.span(state, class: "user_state #{state}")
  end

  # User account status:
  #   invited     - invitation e-mail sent to user, but not accepted
  #   active      - invitation accepted and user has logged in
  #   inactive    - user has not logged in for over a year
  #   deactivated - user has been administratively deactivated
  #   unknown     - any other state
  def account_state(user)
    return :deactivated if user.deactivated_at?
    return :invited     if user.invited_to_sign_up?
    return :unknown     unless user.sign_in_count.positive?
    return :active      if user.current_sign_in_at >= 1.year.ago # within the last year

    :inactive
  end
end
