require 'rails_helper'

RSpec.describe ImportJob do
  let(:ingest) { FactoryBot.create(:ingest) }
  let(:job) { described_class.new(ingest) }

  before do
    # stub calls to sleep in tests
    # TODO: remove this when a full implementation of #process_reocrd is implemented
    allow(job).to receive(:sleep)
  end

  it 'has a real implementation of #process_record' do
    pending 'remove when a real #process_record method is implemented'
    job.perform_now
    expect(job).not_to have_received(:sleep)
  end

  it 'requires an Ingest instance' do
    expect { described_class.perform_now(nil) }.to raise_exception ArgumentError
  end

  describe 'ingest status' do
    it 'upates on enque' do
      described_class.perform_later(ingest)
      ingest.reload
      expect(ingest.status).to eq 'queued'
    end

    it 'updates on perform' do
      allow(job).to receive(:process_record)
      allow(ingest).to receive(:update)
      job.perform_now
      expect(ingest).to have_received(:update).with(status: Ingest.statuses[:processing])
    end

    it 'updates on completion' do
      allow(job).to receive(:process_record)
      job.perform_now
      ingest.reload
      expect(ingest.status).to eq 'completed'
    end

    it 'updates on exceptions' do
      allow(job).to receive(:process_record).and_raise RuntimeError
      job.perform_now
      ingest.reload
      expect(ingest.status).to eq 'errored'
    end
  end

  it 'updates the ingest record processed record count', :aggregate_failures do
    expect(ingest.processed).to eq 0
    job.perform_now
    ingest.reload
    expect(ingest.processed).to eq 2
  end
end
