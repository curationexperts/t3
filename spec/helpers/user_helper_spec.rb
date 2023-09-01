require 'rails_helper'

RSpec.describe UserHelper do
  let(:user) { FactoryBot.build(:user) }

  # Human friendly formatter for login dates
  # returns a <span> element with time span from timestamps
  # the span has the 'login_timestamp' class
  describe '#last_login(user)' do
    it 'returns a span element' do
      user.current_sign_in_at = 3.hours.ago
      expect(last_login(user)).to match(%r{\A<span.*</span>\z})
    end

    it 'returns "ago" for past dates' do
      user.current_sign_in_at = 3.hours.ago
      expect(last_login(user)).to match(%r{ago</span>\z})
    end

    it 'returns "from now" for future dates' do
      user.current_sign_in_at = 3.hours.from_now
      expect(last_login(user)).to match(%r{from now</span>\z})
    end

    it 'returns a duration' do
      user.current_sign_in_at = (6.hours + 50.minutes).ago
      expect(last_login(user)).to match(%r{about 7 hours ago</span>\z})
    end

    it 'returns "never" for nil values' do
      user.current_sign_in_at = nil
      expect(last_login(user)).to eq '<span class="login_timestamp empty">never</span>'
    end
  end

  describe '#duration(timestamp)' do
    it 'returns "n/a" for non-time values' do
      timestamp = 'random value or class'
      expect(duration(timestamp)).to eq '<span class="login_timestamp empty">n/a</span>'
    end
  end
end
