# == Schema Information
#
# Table name: customers
#
#  id             :integer          not null, primary key
#  customer_token :string
#  first_name     :string
#  last_name      :string
#  country        :string
#  zip            :string
#  email          :string
#  created_at     :datetime
#  updated_at     :datetime
#  status         :string           default("live")
#

class Customer < ApplicationRecord
  include LiveMode

  has_many :charges, inverse_of: :customer

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :country, presence: true
  validates :email, presence: true, email_format: true, :uniqueness => {:scope => [:status]}

  accepts_nested_attributes_for :charges

  before_validation :downcase_email

  def downcase_email
    self.email = email.try(:downcase)
  end

  def self.find_or_initialize(customer_params, status: nil)
    customer = where(status: status, email: customer_params[:email].try(:downcase)).first
    if customer.present?
      customer.assign_attributes(customer_params.except(:charges_attributes))
    else
      customer = Customer.new(customer_params.except(:charges_attributes))
    end
    customer.status = status
    customer
  end

  def build_charge_with_params(charges_attributes, config: nil, organization: nil)
    charge = charges.build(charges_attributes.first)
    charge.status = 'live' unless charges_attributes.first[:status] == 'test'
    charge.config = config
    charge.organization = organization
    charge
  end

  def to_hash
    {
      first_name: first_name,
      last_name: last_name,
      country: country,
      zip: zip,
    }
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
