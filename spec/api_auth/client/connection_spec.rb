# frozen_string_literal: true

RSpec.describe ApiAuth::Client::Connection do
  subject(:conn) { described_class.new(url: url) }

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
        let(:executed) { conn.send("#{action}!", path) }

        before do
          stub_request(action, full_url).to_return(body: { some: 'body' }.to_json)
        end

        it "makes a #{action.upcase}" do
          executed
          expect(WebMock).to have_requested(action, full_url).once
        end
      end

      describe "bad ##{action} from server" do
        before do
          stub_request(action, full_url).to_return(status: 400, body: { some: 'error' }.to_json)
        end

        describe 'when non-banged method' do
          let(:executed) { conn.send(action, path) }

          it "#{action.upcase}s and not raise error" do
            expect { executed }.not_to raise_error
            expect(WebMock).to have_requested(action, full_url).once
          end
        end

        describe 'when using banged method' do
          let(:executed) { conn.send("#{action}!", path) }

          it "#{action.upcase}s and raise error" do
            expect { executed }.to raise_error(ApiAuth::Client::ApiEndpointError)
            expect(WebMock).to have_requested(action, full_url).once
          end
        end
      end

      describe "timeout ##{action}" do
        let(:executed) { conn.send("#{action}!", path) }

        before do
          stub_request(action, full_url).to_timeout
        end

        it "#{action.upcase}s and raise error" do
          expect { executed }.to raise_error(ApiAuth::Client::ConnectionError)
          expect(WebMock).to have_requested(action, full_url).once
        end
      end

      describe "Errno::ECONNREFUSED on ##{action}" do
        let(:executed) { conn.send("#{action}!", path) }

        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(RestClient::Request).to receive(:execute).and_raise(Errno::ECONNREFUSED)
          # rubocop:enable RSpec/AnyInstance
        end

        describe 'when non-banged method' do
          let(:executed) { conn.send(action, path) }

          it 'raises an error' do
            expect { executed }.not_to raise_error
          end
        end

        describe 'when using banged method' do
          let(:executed) { conn.send("#{action}!", path) }

          it { expect { executed }.to raise_error(ApiAuth::Client::ConnectionError) }
        end
      end
    end

    context 'with app_id and secret_key' do
      subject(:conn) { described_class.new(url: url, app_id: 'someappid', secret_key: 'app_secret') }

      let(:executed) { conn.send("#{action}!", path) }

      before do
        stub_request(action, full_url).to_return(body: { some: 'body' }.to_json)
                                      .with(headers: { 'Authorization' => /APIAuth someappid:.+/ })
      end

      it "#{action.upcase}s with the right headers" do
        executed
        expect(WebMock).to have_requested(action, full_url).once
      end
    end
  end
end
