require 'rails_helper'
require './spec/models/resource_shared_examples'

RSpec.describe Item do
  it_behaves_like 'a resource'
end
