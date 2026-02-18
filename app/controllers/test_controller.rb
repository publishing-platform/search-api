class TestController < ApplicationController
  def index
    document_hash = {
      content_id: "content-id-1",
      payload_version: 6,
      document_type: "organisation",
      base_path: "/digital-services",
      title: "This is my title",
      description: "This is my description",
      public_updated_at: "2026-01-30T20:41:10Z",
      details: {
        body: [
          { content: "<p>this is some html content</p>", content_type: "text/html" },
        ],
      },
    }
    PublishingApiDocument.new(document_hash)
    # document.synchronize

    another_document_hash = {
      content_id: "content-id-2",
      payload_version: 4,
      document_type: "organisation",
      base_path: "/financial-services",
      title: "This is some content about paper.",
      description: "Paper comes in all sorts of different sizes and is made from trees",
      public_updated_at: "2026-02-01T15:22:16Z",
      details: {
        body: [
          { content: "<p>Red paper, blue paper, green paper</p>", content_type: "text/html" },
        ],
      },
    }

    PublishingApiDocument.new(another_document_hash)
    # another_document.synchronize

    yet_another_document_hash = {
      content_id: "content-id-3",
      payload_version: 12,
      document_type: "answer",
      base_path: "/this-is-my-final-answer",
      title: "This is an answer about tigers.",
      description: "Tigers have black and yellow stripes.",
      public_updated_at: "2026-01-29T08:21:35Z",
      details: {
        body: [
          { content: "<p>Tigers can be very fierce and have very sharp teeth</p>", content_type: "text/html" },
        ],
      },
    }

    PublishingApiDocument.new(yet_another_document_hash)
    # yet_another_document.synchronize

    render json: {}
  end
end
