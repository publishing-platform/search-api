require "rails_helper"
require "publishing_platform_message_queue_consumer/test_helpers"

RSpec.describe PublishingApiMessageProcessor do
  subject(:processor) { described_class.new }

  let(:document) { double(synchronize: nil) }

  it_behaves_like "a message queue processor"

  describe "when receiving an incoming message" do
    let(:message) { PublishingPlatformMessageQueueConsumer::MockMessage.new(payload) }
    let(:payload) { { "I am": "a message" } }
    let(:logger) { instance_double(Logger, info: nil, error: nil) }
    let(:document) { instance_double(PublishingApiDocument, synchronize: nil) }

    before do
      allow(PublishingApiDocument).to receive(:new).with(payload).and_return(document)

      allow(Rails).to receive(:logger).and_return(logger)
      allow(Rails.logger).to receive(:info)
      allow(PublishingPlatformError).to receive(:notify)
    end

    it "acks incoming messages" do
      processor.process(message)

      expect(message).to be_acked
    end

    it "makes the document synchronize itself" do
      processor.process(message)

      expect(document).to have_received(:synchronize)
    end

    context "when synchronising the document fails" do
      let(:error) { RuntimeError.new("Could not synchronize") }

      before do
        allow(document).to receive(:synchronize).and_raise(error)
      end

      it "logs the error" do
        processor.process(message)

        # in ruby version 3.4.0 the Hash#inspect method has been changed so that symbol keys are displayed
        # using the modern symbol key syntax. See https://www.ruby-lang.org/en/news/2024/12/25/ruby-3-4-0-released/
        # Compatibility issues section.  When we upgrade Ruby version to 3.4.0 this test will fail. 
        # To fix, replace this code with commented out code below.        
        expect(logger).to have_received(:error).with(<<~MSG)
          Failed to process incoming document message:
          RuntimeError: Could not synchronize
          Message content: {:\"I am\"=>\"a message\"}
        MSG

        # expect(logger).to have_received(:error).with(<<~MSG)
        #   Failed to process incoming document message:
        #   RuntimeError: Could not synchronize
        #   Message content: {\"I am\": \"a message\"}
        # MSG
      end

      it "sends the error to Sentry" do
        processor.process(message)

        expect(PublishingPlatformError).to have_received(:notify).with(error)
      end

      it "rejects the message" do
        processor.process(message)

        expect(message).not_to be_acked
        expect(message).to be_discarded
      end
    end
  end
end