require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ProgressBarHelperHelper. For example:
#
# describe ProgressBarHelperHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ProgressBarHelper do
  describe '#progress_bar' do
    it 'yields a custom progress bar' do
      expect(helper.progress_bar(5, 100)).to match 'class="status_badge"'
    end

    it 'includes error count when passed' do
      expect(helper.progress_bar(15, 20, 'errored', 5)).to match '5 of 20 errored'
    end
  end

  describe '#width' do
    it 'returns processed / total as a percentage' do
      expect(helper.width(104, 160)).to eq '65%'
    end

    it 'accepts strings that can be cast to integers' do
      expect(helper.width('15', '20')).to eq '75%'
    end

    it 'returns "100%" when flagged' do
      expect(helper.width(0, 25, 'queued')).to eq '100%'
    end

    describe 'invalid data returns "100%"' do
      example 'for division by 0' do
        expect(helper.width('anything', 0)).to eq '100%'
      end

      example 'for non-integer divisors' do
        expect(helper.width('anything', 'not-a-number')).to eq '100%'
      end
    end
  end

  describe '#message' do
    it 'returns "x of y" when processed != total' do
      expect(helper.message(104, 160)).to eq '104 of 160'
    end

    it 'accepts string values' do
      expect(helper.message('5', 'unknown')).to eq '5 of unknown'
    end

    it 'returns status when passed' do
      expect(helper.message(0, 0, 'errored')).to eq '0 errored'
    end

    it 'suppresses processed=0 when queued' do
      expect(helper.message(0, 25, 'queued')).to eq '25 queued'
    end
  end
end
