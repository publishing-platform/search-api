require "rails_helper"

RSpec.describe Result, type: :model do
  describe ".from_stored_document" do
    subject(:result) { described_class.from_stored_document(stored_document) }

    let(:stored_document) do
      {
        "content_id" => "12345",
        "title" => "Sample Title",
        "link" => "/sample-link",
        "description" => "Sample Description",
        "document_type" => "news_story",
      }
    end

    it "creates a new Result instance with the correct attributes" do
      expect(result).to have_attributes(
        id: "12345",
        content_id: "12345",
        title: "Sample Title",
        link: "/sample-link",
        description: "Sample Description",
        document_type: "news_story",
      )
    end

    context "when document represents an organisation" do
      let(:stored_document) do
        {
          "content_id" => "12345",
          "title" => "Sample Title",
          "link" => "/sample-link",
          "description" => "Sample Description",
          "document_type" => "organisation",
          "organisation_status" => "live",
          "organisation_type" => "department",
          "organisation_abbreviation" => "ds",
        }
      end

      it "creates a new Result instance with additional organisation attributes" do
        expect(result).to have_attributes(
          id: "12345",
          content_id: "12345",
          title: "Sample Title",
          link: "/sample-link",
          description: "Sample Description",
          document_type: "organisation",
          organisation_status: "live",
          organisation_type: "department",
          organisation_abbreviation: "ds",
        )
      end
    end

    context "when document data is missing or incomplete" do
      let(:stored_document) { {} }

      it "handles missing or incomplete data gracefully" do
        expect { result }.not_to raise_error
      end
    end

    context "when the description is excessively long" do
      let(:description) { "buffalo " * 50 }
      let(:stored_document) { { description: } }

      it "truncates the description" do
        buffalos = ("buffalo " * 40).strip
        expect(result.description).to eq("#{buffalos}...")
      end
    end
  end
end
