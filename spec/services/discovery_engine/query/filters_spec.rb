RSpec.describe DiscoveryEngine::Query::Filters do
  describe "#filter_expression" do
    subject(:filter_expression) { described_class.new(query_params).filter_expression }

    context "when no relevant query params are present" do
      let(:query_params) { {} }

      it { is_expected.to be_nil }
    end

    context "with a reject string filter" do
      context "with an empty parameter" do
        let(:query_params) { { q: "garden centres", reject_link: "" } }

        it { is_expected.to be_nil }
      end

      context "with a single parameter" do
        let(:query_params) { { q: "garden centres", reject_link: "/foo" } }

        it { is_expected.to eq('NOT link: ANY("/foo")') }
      end

      context "with several parameters" do
        let(:query_params) { { q: "garden centres", reject_link: ["/foo", "/bar"] } }

        it { is_expected.to eq('NOT link: ANY("/foo","/bar")') }
      end

      context "with an unknown field" do
        let(:query_params) { { q: "garden centres", reject_foo: "bar" } }

        it { is_expected.to be_nil }
      end

      context "with invalid characters in the filter value" do
        let(:query_params) { { q: "garden centres", reject_link: "foo\u0000bar" } }

        it { is_expected.to be_nil }
      end
    end

    context "with an 'any' string filter" do
      context "with an empty parameter" do
        let(:query_params) { { q: "garden centres", filter_document_type: "" } }

        it { is_expected.to be_nil }
      end

      context "with a single parameter" do
        let(:query_params) do
          { q: "garden centres", filter_document_type: "news_story" }
        end

        it { is_expected.to eq('document_type: ANY("news_story")') }
      end

      context "with several parameters" do
        let(:query_params) do
          { q: "garden centres", filter_document_type: %w[news_story guidance] }
        end

        it { is_expected.to eq('document_type: ANY("news_story","guidance")') }
      end

      context "with common garbled query parameters" do
        let(:query_params) do
          { q: "garden centres", filter_document_type: { "\\\\\\\\" => "oops" } }
        end

        it { is_expected.to be_nil }
      end

      context "with invalid characters in the filter value" do
        let(:query_params) { { q: "garden centres", filter_link: "foo\u0000bar" } }

        it { is_expected.to be_nil }
      end

      context "with an unknown field" do
        let(:query_params) { { q: "garden centres", filter_foo: "bar" } }

        it { is_expected.to be_nil }
      end
    end

    context "with an 'all' string filter" do
      context "with an empty parameter" do
        let(:query_params) { { q: "garden centres", filter_all_document_type: "" } }

        it { is_expected.to be_nil }
      end

      context "with a single parameter" do
        let(:query_params) { { q: "garden centres", filter_all_document_type: "news_story" } }

        it { is_expected.to eq('document_type: ANY("news_story")') }
      end

      context "with several parameters" do
        let(:query_params) do
          { q: "garden centres", filter_all_document_type: %w[news_story guidance] }
        end

        # this test is obviously unrealistic for the document_type field but it verifies that multiple values are combined with AND for the 'all' filter type
        it { is_expected.to eq('(document_type: ANY("news_story")) AND (document_type: ANY("guidance"))') }
      end

      context "with common nonsencial hash query parameters" do
        let(:query_params) do
          { q: "garden centres", filter_all_document_type: { "\\\\\\\\" => "oops" } }
        end

        it { is_expected.to be_nil }
      end

      context "with invalid characters in the filter value" do
        let(:query_params) { { q: "garden centres", filter_all_link: "foo\u0000bar" } }

        it { is_expected.to be_nil }
      end

      context "with an unknown field" do
        let(:query_params) { { q: "garden centres", filter_all_foo: "bar" } }

        it { is_expected.to be_nil }
      end
    end

    context "with a timestamp filter" do
      context "with an empty parameter" do
        let(:query_params) { { q: "garden centres", filter_public_timestamp: "" } }

        it { is_expected.to be_nil }
      end

      context "with a from parameter" do
        let(:query_params) { { q: "garden centres", filter_public_timestamp: "from:1989-12-13" } }

        it { is_expected.to eq("public_timestamp: IN(629510400,*)") }
      end

      context "with a to parameter" do
        let(:query_params) { { q: "garden centres", filter_public_timestamp: "to:1989-12-13" } }

        it { is_expected.to eq("public_timestamp: IN(*,629596799)") }
      end

      context "with both from and to parameters" do
        let(:query_params) { { q: "garden centres", filter_public_timestamp: "from:1989-12-13,to:1989-12-13" } }

        it { is_expected.to eq("public_timestamp: IN(629510400,629596799)") }
      end

      context "with both from and to parameters but the wrong way around" do
        let(:query_params) { { q: "garden centres", filter_public_timestamp: "from:1989-12-14,to:1989-12-13" } }

        it { is_expected.to eq("public_timestamp: IN(629510400,629683199)") }
      end

      context "with an invalid from parameter" do
        let(:query_params) { { q: "garden centres", filter_public_timestamp: "from:1989" } }

        it { is_expected.to be_nil }
      end

      context "with an invalid to parameter" do
        let(:query_params) { { q: "garden centres", filter_public_timestamp: "to:12-13" } }

        it { is_expected.to be_nil }
      end

      context "with an invalid filter_all type" do
        let(:query_params) { { q: "garden centres", filter_all_public_timestamp: "from:1989-12-13" } }

        it { is_expected.to be_nil }
      end

      context "with an invalid reject type" do
        let(:query_params) { { q: "garden centres", reject_public_timestamp: "from:1989-12-13" } }

        it { is_expected.to be_nil }
      end
    end

    context "with several filters specified" do
      let(:query_params) do
        {
          q: "garden centres",
          reject_link: "/foo",
          filter_document_type: "guidance",
          filter_all_link: %w[/bar /baz],
          filter_public_timestamp: "from:1989-12-13,to:1989-12-13",
        }
      end

      it { is_expected.to eq('(NOT link: ANY("/foo")) AND (document_type: ANY("guidance")) AND ((link: ANY("/bar")) AND (link: ANY("/baz"))) AND (public_timestamp: IN(629510400,629596799))') }
    end
  end
end
