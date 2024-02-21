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
      allow(job).to receive(:process_record).and_return({ status: 'created' })
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
      expect(ingest.status).to eq 'queued'
    end

    it 'updates on perform' do
      allow(job).to receive(:process_record).and_return({ status: 'created' })
      allow(ingest).to receive(:update)
      job.perform_now
      expect(ingest).to have_received(:update).with(status: Ingest.statuses[:processing])
    end

    it 'updates on completion' do
      allow(job).to receive(:process_record).and_return({ status: 'created' })
      job.perform_now
      expect(ingest.status).to eq 'completed'
    end

    it 'updates on exceptions' do
      allow(job).to receive(:process_record).and_raise RuntimeError
      job.perform_now
      expect(ingest.status).to eq 'errored'
    end
  end

  it 'updates the ingest record processed record count', :aggregate_failures do
    allow(job).to receive(:process_record).and_return({ status: 'created' })
    expect(ingest.processed).to eq 0
    job.perform_now
    expect(ingest.processed).to eq 2
  end

  describe 'status report' do
    it 'gets attached at job completion' do
      allow(job).to receive(:process_record).and_return({ status: 'created' })
      job.perform_now
      expect(ingest.report).to be_attached
    end

    it 'includes job metrics', :aggregate_failures do
      allow(job).to receive(:process_record).and_return({ status: 'created' })
      job.perform_now
      report = JSON.parse(ingest.report.download, { symbolize_names: true })
      expect(report).to include(
        context: a_hash_including(
          status: 'completed',
          submitted: /\A\d{4}-\d{2}-\d{2}/,
          finished: /\d{2}\.\d{3}Z\z/,
          submitted_by: ingest.user.display_name
        ),
        items: a_kind_of(Array)
      )
    end

    context 'with errors' do
      before do
        # Simulate an error on creating one of two records
        allow(Item).to receive(:create) do |params|
          raise 'Testing exception handling' if params[:description]['title_ssi'].match?(/Admiral/)

          Item.new(id: 1)
        end
      end

      it 'captures errors', :aggregate_failures do
        job.perform_now
        expect(ingest).to be_errored
        report = JSON.parse(ingest.report.download, { symbolize_names: true })
        expect(report).to include(
          context: a_hash_including(
            status: 'errored',
            submitted: /\d{4}-\d{2}-\d{2}/,
            started: /\d{4}-\d{2}-\d{2}/,
            finished: /\d{4}-\d{2}-\d{2}/,
            submitted_by: ingest.user.display_name,
            processed: 2,
            errored: 1
          ),
          items: include(a_hash_including(message: 'Testing exception handling'))
        )
      end
    end
  end
end
