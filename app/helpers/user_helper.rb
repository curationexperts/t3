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

    suffix = timestamp < Time.now.utc ? ' ago' : ' from now'
    duration_text = time_ago_in_words(timestamp) + suffix
    tag.span(duration_text, class: 'login_timestamp', datetime: timestamp.iso8601)
  rescue StandardError
    tag.span('n/a', class: 'login_timestamp empty')
  end
end
