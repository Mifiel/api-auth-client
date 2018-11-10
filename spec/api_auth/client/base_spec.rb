# frozen_string_literal: true

RSpec.describe ApiAuth::Client::Base do
  class MyClient < ApiAuth::Client::Base
    connect url: 'https://example.com',
            app_id: 'some-app-id',
            secret_key: 'some-secret-key'

    def some_method
      connection.post('/some/action')
    end
  end

  let(:client) { MyClient.new }

  describe 'a inherited class' do
    let!(:full_url) { 'https://example.com/some/action' }

    before do
      stub_request(:post, full_url).to_return(body: { some: 'body' }.to_json)
    end

    it 'inherits a connection' do
      response = client.some_method
      expect(response.some).to eql('body')
      expect(WebMock).to have_requested(:post, full_url).once
    end
  end
end
