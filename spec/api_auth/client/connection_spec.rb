# frozen_string_literal: true

RSpec.describe ApiAuth::Client::Connection do
  subject(:conn) { described_class.new(url) }

  let!(:url) { 'https://www.example.com' }
  let!(:full_url) { "#{url}/#{path}" }

  let!(:path) { 'api/v1/tickers' }

  %i[
    get
    post
    put
    delete
  ].each do |action|
    context 'without app_id nor secret_key' do
      describe "good ##{action}" do
        let(:executed) { conn.send(action, path) }

        before do
          stub_request(action, full_url).to_return(body: { some: 'body' }.to_json)
        end

        it "makes a #{action.upcase}" do
          executed
          expect(WebMock).to have_requested(action, full_url).once
        end

        it 'is able to read the response' do
          expect(executed[:some]).to eql('body')
          expect(executed['some']).to eql('body')
          expect(executed.some).to eql('body')
          expect(executed.code).to be(200)
        end

        context 'when calling to an undefined method in the response' do
          it 'raises an error' do
            expect { executed.bad_param }.to raise_error(NoMethodError)
            expect(executed[:bad_param]).to be_nil
            expect(executed['bad_param']).to be_nil
          end
        end
      end

      context 'when response is not json' do
        let(:executed) { conn.send(action, path) }

        before do
          stub_request(action, full_url).to_return(body: 'some non-json body')
        end

        it "makes a #{action.upcase}" do
          executed
          expect(WebMock).to have_requested(action, full_url).once
        end

        it 'is able to read the response' do
          expect(executed.body).to eql('some non-json body')
          expect(executed.code).to be(200)
        end
      end

      describe "bad ##{action} from server" do
        let(:executed) { conn.send(action, path) }

        before do
          stub_request(action, full_url).to_return(status: 400, body: { some: 'error' }.to_json)
        end

        it "should #{action.upcase} and raise error" do
          expect { executed }.to raise_error(ApiAuth::Client::ApiEndpointError)
          expect(WebMock).to have_requested(action, full_url).once
        end

        it 'is able to read the response when rescued' do # rubocop:disable RSpec/ExampleLength
          begin
            executed
          rescue ApiAuth::Client::ApiEndpointError => e
            response = e.response
            expect(response[:some]).to eql('error')
            expect(response['some']).to eql('error')
            expect(response.some).to eql('error')
            expect(response.code).to be(400)
          end
        end
      end

      describe "timeout ##{action}" do
        before do
          stub_request(action, full_url).to_timeout
        end

        it "should #{action.upcase} and raise error" do
          expect { conn.send(action, path) }.to raise_error(ApiAuth::Client::ConnectionError)
          expect(WebMock).to have_requested(action, full_url).once
        end
      end
    end

    context 'with app_id and secret_key' do
      subject(:conn) { described_class.new(url, app_id: 'someappid', secret_key: 'app_secret') }

      let(:executed) { conn.send(action, path) }

      before do
        stub_request(action, full_url).to_return(body: { some: 'body' }.to_json)
                                      .with(headers: { 'Authorization' => /APIAuth someappid:.+/ })
      end

      it "should #{action.upcase} with the right headers" do
        executed
        expect(WebMock).to have_requested(action, full_url).once
      end
    end
  end
end
