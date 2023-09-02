require 'rails_helper'

RSpec.describe UserHelper do
  let(:user) { FactoryBot.build(:user) }

  # Human friendly formatter for login dates
  # returns a <span> element with time span from timestamps
  # the span has the 'login_timestamp' class
  describe '#last_login' do
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

  describe '#duration' do
    it 'returns "n/a" for non-time values' do
      timestamp = 'random value or class'
      expect(duration(timestamp)).to eq '<span class="login_timestamp empty">n/a</span>'
    end
  end

  describe '#status_badge' do
    it 'returns a span element' do
      expect(status_badge(user)).to match(%r{\A<span.*</span>\z})
    end

    it 'returns "invited" for invited users' do
      user = User.invite!(email: 'new_user@example.com')
      expect(status_badge(user)).to match(/invited/)
    end

    it 'returns "active" for users who have logged in at least once' do
      user.sign_in_count = 1
      user.current_sign_in_at = 2.months.ago
      expect(status_badge(user)).to match(/active/)
    end

    it 'returns "inactive" for users who not logged in for over a year' do
      user.sign_in_count = 150
      user.current_sign_in_at = (1.year + 1.week).ago
      expect(status_badge(user)).to match(/inactive/)
    end

    it 'returns "unknown" if all else fails' do
      # i.e. user object has never been persisted
      expect(status_badge(user)).to match(/unknown/)
    end

    it 'returns nothing if called with non-user object' do
      expect(status_badge(Object.new)).to be_nil
    end
  end
end
