require 'rails_helper'

RSpec.describe ImportJob do
  let(:ingest) { FactoryBot.create(:ingest) }
  let(:job) { described_class.new(ingest) }

  describe '#process_record', :solr do
    let(:doc) do
      {
        'has_model_ssim' => ['Book'],
        'title_tesi' => 'Anna Karenina',
        'author_tesim' => ['Tolstoy, Lev Nikolayevich', 'Tolstoy, Leo', 'Толстой, Лев Николаевич'],
        'date_isi' => 1878
      }
    end

    before do
      stub_solr
      Blueprint.create(name: 'Book')
    end

    it 'gets called once for each item in the manifest' do
      allow(job).to receive(:process_record)
      job.perform_now
      expect(job).to have_received(:process_record).exactly(2).times
    end

    it 'creates a new Item' do
      expect { job.process_record(doc) }.to change(Item, :count).by(1)
    end

    it 'maps metadata according to the blueprint' do
      FactoryBot.create(:field, name: 'Title', data_type: 'text_en', source_field: 'title_tesi')
      FactoryBot.create(:field, name: 'Author', data_type: 'text_en', multiple: true, source_field: 'author_tesim')
      FactoryBot.create(:field, name: 'Date', data_type: 'integer', source_field: 'date_isi')

      job.process_record(doc)
      expect(Item.last.description).to include('Title' => 'Anna Karenina',
                                               'Author' => ['Tolstoy, Lev Nikolayevich',
                                                            'Tolstoy, Leo', 'Толстой, Лев Николаевич'],
                                               'Date' => 1878)
    end
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
    allow(job).to receive(:process_record)
    expect(ingest.processed).to eq 0
    job.perform_now
    ingest.reload
    expect(ingest.processed).to eq 2
  end
end
