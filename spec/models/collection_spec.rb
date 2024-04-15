require 'rails_helper'
require './spec/models/resource_shared_examples'

RSpec.describe Collection do
  it_behaves_like 'a resource'
end
