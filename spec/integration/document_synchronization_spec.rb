require "rails_helper"
require "publishing_platform_message_queue_consumer/test_helpers"

RSpec.describe "Document synchronization" do
  let(:message) { PublishingPlatformMessageQueueConsumer::MockMessage.new(payload) }

  let(:put_service) { instance_double(DiscoveryEngine::Sync::Put, call: nil) }
  let(:delete_service) { instance_double(DiscoveryEngine::Sync::Delete, call: nil) }

  before do
    allow(DiscoveryEngine::Sync::Put).to receive(:new).and_return(put_service)
    allow(DiscoveryEngine::Sync::Delete).to receive(:new).and_return(delete_service)

    Timecop.freeze(Time.zone.local(1989, 12, 13, 1, 2, 3)) do
      PublishingApiMessageProcessor.new.process(message)
    end
  end

  describe "for a 'news_story' message" do
    let(:payload) { json_fixture_as_hash("message_queue/news_story_message.json") }

    it "is added to Discovery Engine through the Put service" do
      expect(DiscoveryEngine::Sync::Put).to have_received(:new).with(
        "1cf744dd-2ba1-4ed6-acbe-7b73d232165f",
        {
          content_id: "1cf744dd-2ba1-4ed6-acbe-7b73d232165f",
          title: "A test news story",
          description: "A test news story description",
          link: "/news/a-test-news-story",
          public_timestamp: 1_769_805_670,
          public_timestamp_datetime: "2026-01-30T20:41:10Z",
          url: "https://www.publishing-platform.co.uk/news/a-test-news-story",
          document_type: "news_story",
          debug: {
            last_synced_at: "1989-12-13T01:02:03+00:00",
            payload_version: 51,
          },
        },
        content: a_string_including("<h1 id=\"a-test-news-story\">A test news story</h1>"),
        payload_version: 51,
      )
      expect(put_service).to have_received(:call)
    end
  end

  describe "for an 'organisation' message" do
    let(:payload) { json_fixture_as_hash("message_queue/organisation_message.json") }

    it "is added to Discovery Engine through the Put service" do
      expect(DiscoveryEngine::Sync::Put).to have_received(:new).with(
        "af07d5a5-df63-4ddc-9383-6a666845ebe9",
        {
          content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9",
          title: "Digital Services",
          description: "We deliver digital services for the publishing platform.",
          link: "/organisations/digital-services",
          public_timestamp: 1_769_804_201,
          public_timestamp_datetime: "2026-01-30T20:16:41Z",
          url: "https://www.publishing-platform.co.uk/organisations/digital-services",
          document_type: "organisation",
          organisation_status: "live",
          organisation_type: "department",
          organisation_abbreviation: "DS",
          slug: "digital-services",
          debug: {
            last_synced_at: "1989-12-13T01:02:03+00:00",
            payload_version: 12_345,
          },
        },
        content: a_string_including("We deliver digital services"),
        payload_version: 12_345,
      )
      expect(put_service).to have_received(:call)
    end
  end

  describe "for a 'gone' message" do
    let(:payload) { json_fixture_as_hash("message_queue/gone_message.json") }

    it "is deleted from Discovery Engine through the Delete service" do
      expect(DiscoveryEngine::Sync::Delete).to have_received(:new).with(
        "1cf744dd-2ba1-4ed6-acbe-7b73d232165f",
        payload_version: 53,
      )
      expect(delete_service).to have_received(:call)
    end
  end
end
