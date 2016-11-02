require 'spec_helper'

describe AuthoritiesController do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  describe "#index" do
    it { expect(get(:index)).to be_success }

    it 'assigns a mapping of states to authorities to the view' do
      nsw_auth = create(:authority, state: 'NSW')
      vic_auth = create(:authority, state: 'VIC')

      get :index
      expect(assigns[:authorities]).to eq({'NSW' => [nsw_auth],
                                           'VIC' => [vic_auth]})
    end

  end
end
