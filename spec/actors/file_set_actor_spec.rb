require 'spec_helper'

describe Sufia::FileSetActor do
  include ActionDispatch::TestProcess

  let(:user) { create(:user) }
  let(:file_set) { create(:file_set) }
  let(:actor) { described_class.new(file_set, user) }
  let(:uploaded_file) { fixture_file_upload('/world.png', 'image/png') }
  let(:local_file) { File.open(File.join(fixture_path, 'world.png')) }

  describe 'creating metadata and content' do
    let(:upload_set_id) { nil }
    let(:work) { nil }
    subject { file_set.reload }
    let(:date_today) { DateTime.now }

    before do
      allow(DateTime).to receive(:now).and_return(date_today)
    end

    before do
      expect(CharacterizeJob).to receive(:perform_later)
      expect(IngestFileJob).to receive(:perform_later).with(file_set.id, /world\.png$/, 'image/png', user.user_key)
      allow(actor).to receive(:acquire_lock_for).and_yield
      actor.create_metadata(upload_set_id, work)
      actor.create_content(uploaded_file)
    end

    context "when no work is provided" do
      it "assigns a default one" do
        expect(subject.generic_works.first.title).to contain_exactly("Default title")
      end
    end
  end
end
