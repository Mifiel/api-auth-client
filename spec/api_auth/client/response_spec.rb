# frozen_string_literal: true

RSpec.describe ApiAuth::Client::Response do
  subject(:response) { described_class.new(rest_response) }

  let(:code) { 200 }
  let(:net_http_res) { instance_double('net http response', to_hash: { 'Status' => ["#{code} OK"] }, code: code) }
  let(:url) { 'https://example.com' }
  let(:request) do
    instance_double('request', url: url, uri: URI.parse(url), method: :get,
                               user: nil, password: nil, cookie_jar: HTTP::CookieJar.new,
                               redirection_history: nil, args: { url: url, method: :get },)
  end
  let(:body) { { some: 'body' }.to_json }
  let(:rest_response) { RestClient::Response.create(body, net_http_res, request) }

  context 'when good param' do
    it 'is able to read the response' do
      expect(response[:some]).to eql('body')
      expect(response['some']).to eql('body')
      expect(response.some).to eql('body')
      expect(response.code).to be(code)
    end

    it 'responds to missing methods' do
      expect(response.method(:code)).to be_a Method
    end

    it 'raises an error if calls to an undefined param' do
      expect { response.bad_param }.to raise_error(NoMethodError)
    end

    it 'does not raises if called as json or hash' do
      expect(response[:bad_param]).to be_nil
      expect(response['bad_param']).to be_nil
    end
  end

  context 'when bad param' do
    it { expect { described_class.new('some-data') }.to raise_error ArgumentError }
  end

  describe '#ok?' do
    context 'when code > 200 < 400' do
      let(:code) { 201 }

      it { expect(response.ok?).to be true }
    end

    context 'when code >= 400' do
      let(:code) { 400 }

      it { expect(response.ok?).to be false }
    end
  end

  describe '#inspect' do
    it { expect(response.inspect).to include('ApiAuth::Client::Response') }
  end

  describe '#to_json' do
    context 'when json body' do
      it { expect(response.to_json).to be_a Hash }
      it { expect(response.to_json['error']).to be_nil }
    end

    context 'when string body' do
      let(:body) { 'bad-body' }

      it { expect(response.to_json).to be_a Hash }
      it { expect(response.to_json['error']).to eql('Bad JSON') }
    end
  end
end
