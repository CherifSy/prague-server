require 'spec_helper'

describe ChargeNotificationMailer do
  describe 'send_receipt' do
    subject{ ActionMailer::Base.deliveries.last }

    let(:charge) { create(:charge, customer: create(:customer), organization: create(:organization))}
    
    before do
      charge
      charge.organization.update_attribute(:thank_you_text, "Thank yew")
      ChargeNotificationMailer.send_receipt(charge.id).deliver
    end

    its(:to){ should == [charge.customer.email] }
    its(:from){ should == ["admin@takecharge.io"] }
    its(:subject){ should == "Thanks for donating to #{charge.organization.name}"}

    it 'should give the thank you text and other useful info' do
      subject.body.should have_content(charge.organization.thank_you_text)
    end
  end
end