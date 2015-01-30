require 'spec_helper'

describe Org::Tags::ChargesController do
  let(:organization) { create(:organization)}
  let(:tag) { create(:tag, name: 'foo', organization: organization) }
  let(:charge) { create(:charge, tag: tag, organization: organization) }
  let(:user) { create(:confirmed_user, organization: organization)}

  before(:each) do
    controller.stub(:current_organization).and_return( organization )
    sign_in user
  end

  it 'should get index' do
    get :index, tag_id: tag, organization_id: organization, format: 'csv'
    response.should be_success
  end
end