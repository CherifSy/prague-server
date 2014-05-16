class ChargeCustomerWorker
  include Sidekiq::Worker

  def perform(charge_id)
    charge = Charge.find(charge_id)
    token = Stripe::Token.create(
      {
        customer: charge.customer.customer_token
      },
      charge.organization.access_token
    )
    Stripe::Charge.create({
        amount: charge.amount,
        currency: charge.currency,
        application_fee: charge.application_fee,
        card: token.id,
        description: "#{Time.zone.now.to_s} - #{charge.customer.id} - #{charge.organization.slug}"
      },
      charge.organization.access_token
    )
    Pusher[charge.pusher_channel_token].trigger('charge_completed', {
      status: 'success'
    })
    CrmNotificationWorker.perform_async(charge_id)
    ChargeNotificationMailer.delay.send_receipt(charge_id)
  rescue Stripe::CardError => e
    Pusher[charge.pusher_channel_token].trigger('charge_completed', {
      status: 'failure',
      message: e.message
    })
  rescue Stripe::StripeError => e
    Pusher[charge.pusher_channel_token].trigger('charge_completed', {
      status: 'failure',
      message: "Something went wrong, please try again."
    })
  end
end
