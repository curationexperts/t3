# Vanity Domains
class CustomDomain < ApplicationRecord
  validates :host, presence: true
  validates :host, format: { with: Certificate::DOMAIN_PATTERN, message: 'must be a valid DNS hostname' },
                   allow_blank: true
  validate :host_can_be_resolved

  def host_can_be_resolved; end
end
