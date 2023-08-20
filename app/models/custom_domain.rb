# Vanity Domains
class CustomDomain < ApplicationRecord
  validates :host, presence: true
  validates :host, uniqueness: true
  validates :host, format: { with: Certificate::DOMAIN_PATTERN, message: 'must be a valid DNS hostname' },
                   allow_blank: true
  validate :certbot_success

  before_save :update_certificate

  def certbot_success
    if certbot_client.invalid?
      errors.add(:base, :certbot, message: 'could not initialize Certbot')
    elsif certbot_client.last_error.present?
      errors.add(:host, :certificate, message: "certificate update error text:\n#{certbot_client.last_error}")
    end
  end

  def update_certificate
    success = certbot_client.add_host(host)
    raise ActiveRecord::RecordInvalid unless success
  end

  def certbot_client
    @certbot_client ||= Certbot::V2::Client.new
  end
end
