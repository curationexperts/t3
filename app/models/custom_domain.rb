# Vanity Domains
class CustomDomain < ApplicationRecord
  validates :host, presence: true
  validates :host, uniqueness: true
  validates :host, format: { with: Certificate::DOMAIN_PATTERN, message: 'must be a valid DNS hostname' },
                   allow_blank: true
  validate :host_can_be_resolved
  validate :certbot_success

  before_save :update_certificate

  def host_can_be_resolved; end

  def certbot_success
    if certbot_client.invalid?
      errors.add(:base, :certbot, message: 'could not initialize Certbot')
    elsif certbot_client.last_error.present?
      errors.add(:host, :certificate, message: "certificate update error text:\n#{certbot_client.last_error}")
    else
      # no certbot errors
      return true
    end
    false
  end

  def initialize(attributes = nil)
    super
  end

  def update_certificate
    certbot_client.add_host(host)
    raise ActiveRecord::RecordInvalid unless certbot_success
  end

  def certbot_client
    @certbot_client ||= Certbot::V2::Client.new
  end
end
