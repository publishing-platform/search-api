require "rails_helper"

RSpec.describe PublishingApi::Metadata do
  subject(:concern_consumer) { Struct.new(:document_hash).include(described_class) }

  describe "#metadata" do
    subject(:extracted_metadata) { concern_consumer.new(document_hash).metadata }

    describe "content_id" do
      subject(:extracted_content_id) { extracted_metadata[:content_id] }

      let(:document_hash) { { content_id: "000-000-000" } }

      it { is_expected.to eq("000-000-000") }
    end

    describe "title" do
      subject(:extracted_title) { extracted_metadata[:title] }

      let(:document_hash) { { title: "Hello world" } }

      it { is_expected.to eq("Hello world") }

      context "when the title contains leading and trailing whitespace" do
        let(:document_hash) { { title: "  Hello world  " } }

        it { is_expected.to eq("Hello world") }
      end

      context "without a title" do
        let(:document_hash) { {} }

        it { is_expected.to be_nil }
      end
    end

    describe "description" do
      subject(:extracted_description) { extracted_metadata[:description] }

      let(:document_hash) { { description: "Lorem ipsum dolor sit amet." } }

      it { is_expected.to eq("Lorem ipsum dolor sit amet.") }
    end

    describe "link" do
      subject(:extracted_link) { extracted_metadata[:link] }

      context "with a base_path" do
        let(:document_hash) { { base_path: "/test" } }

        it { is_expected.to eq("/test") }
      end

      context "without a base_path" do
        let(:document_hash) { {} }

        it { is_expected.to be_nil }
      end
    end

    describe "url" do
      subject(:extracted_url) { extracted_metadata[:url] }

      context "with a base_path" do
        let(:document_hash) { { base_path: "/test" } }

        it { is_expected.to eq("https://www.publishing-platform.co.uk/test") }
      end

      context "without a base_path" do
        let(:document_hash) { {} }

        it { is_expected.to be_nil }
      end
    end

    describe "document_type" do
      subject(:extracted_document_type) { extracted_metadata[:document_type] }

      let(:document_hash) { { document_type: "foo_bar" } }

      it { is_expected.to eq("foo_bar") }
    end

    describe "debug" do
      subject(:extracted_debug) { extracted_metadata[:debug] }

      let(:document_hash) { { payload_version: "42" } }

      it "includes the last sync timestamp" do
        Timecop.freeze(Time.zone.local(1989, 12, 13, 11, 22, 33)) do
          expect(extracted_debug[:last_synced_at]).to eq("1989-12-13T11:22:33Z")
        end
      end

      it "includes the payload version as an integer" do
        expect(extracted_debug[:payload_version]).to eq(42)
      end
    end
  end
end
