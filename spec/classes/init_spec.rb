require 'spec_helper'
describe 'demo_mco_client' do
  context 'with default values for all parameters' do
    it { should contain_class('demo_mco_client') }
  end
end
