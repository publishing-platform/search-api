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

    describe "public_timestamp" do
      subject(:extracted_public_timestamp) { extracted_metadata[:public_timestamp] }

      let(:document_hash) { { public_updated_at: "2012-02-01T00:00:00Z" } }

      it { is_expected.to eq(1_328_054_400) }

      context "without a public_timestamp" do
        let(:document_hash) { {} }

        it { is_expected.to be_nil }
      end
    end

    describe "public_timestamp_datetime" do
      subject(:extracted_public_timestamp_datetime) { extracted_metadata[:public_timestamp_datetime] }

      let(:document_hash) { { public_updated_at: "2012-02-01T00:00:00Z" } }

      it { is_expected.to eq("2012-02-01T00:00:00Z") }

      context "without a public_timestamp" do
        let(:document_hash) { {} }

        it { is_expected.to be_nil }
      end
    end

    context "when the document is an organisation" do
      let(:document_hash) do
        {
          base_path: "/organisations/digital-services",
          document_type: "organisation",
          details: {
            status: "live",
            organisation_type: "department",
            abbreviation: "DS",
          },
        }
      end
      describe "organisation_status" do
        subject(:extracted_organisation_status) { extracted_metadata[:organisation_status] }

        it { is_expected.to eq("live") }
      end

      describe "organisation_type" do
        subject(:extracted_organisation_type) { extracted_metadata[:organisation_type] }

        it { is_expected.to eq("department") }
      end

      describe "organisation_abbreviation" do
        subject(:extracted_organisation_abbreviation) { extracted_metadata[:organisation_abbreviation] }

        it { is_expected.to eq("DS") }
      end

      describe "slug" do
        subject(:extracted_slug) { extracted_metadata[:slug] }

        it { is_expected.to eq("digital-services") }
      end
    end

    describe "debug" do
      subject(:extracted_debug) { extracted_metadata[:debug] }

      let(:document_hash) { { payload_version: "42" } }

      it "includes the last sync timestamp" do
        Timecop.freeze(Time.zone.local(1989, 12, 13, 11, 22, 33)) do
          expect(extracted_debug[:last_synced_at]).to eq("1989-12-13T11:22:33+00:00")
        end
      end

      it "includes the payload version as an integer" do
        expect(extracted_debug[:payload_version]).to eq(42)
      end
    end
  end
end
