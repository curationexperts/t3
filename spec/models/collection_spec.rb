require 'rails_helper'
require './spec/models/resource_shared_examples'
require './spec/models/indexed_resource_shared_examples'

RSpec.describe Collection do
  it_behaves_like 'a resource'
  it_behaves_like 'an indexed resource'
end
