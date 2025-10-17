require "rails_helper"

RSpec.describe PublishingApi::Content do
  subject(:concern_consumer) { Struct.new(:document_hash).include(described_class) }

  describe "#content" do
    subject(:extracted_content) { concern_consumer.new(document_hash).content }

    describe "with basic top-level fields" do
      let(:document_hash) do
        {
          title: "a",
          description: "b",
          details: {
            abbreviation: "c",
            body: "d",
          },
        }
      end

      it { is_expected.to eq("a\nb\nc\nd") }
    end

    describe "with excessively large content" do
      let(:document_hash) do
        {
          details: {
            body: "a" * 1200.kilobytes,
          },
        }
      end

      it "truncates the content" do
        expect(extracted_content.bytesize).to be < 1_000_000
      end
    end

    describe "without any fields" do
      let(:document_hash) do
        {
          details: {},
        }
      end

      it { is_expected.to be_blank }
    end
  end
end
