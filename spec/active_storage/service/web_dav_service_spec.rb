RSpec.describe ActiveStorage::Service::WebDAVService do
  let(:key) { 'some-resource-key' }
  let(:file) { 'some-io-object' }

  subject(:web_dav_service) { described_class.new(url: "http://localhost:2080/imports/") }

  describe '#upload' do
    it 'загрузка файла' do
      expect(web_dav_service).to receive(:upload).with(file, public_id: key)

      web_dav_service.upload(file, {:public_id=>key})
    end
  end

  describe '#url' do
    it 'получение урл' do
      expect(web_dav_service)
        .to receive(:url)
        .with(key)
        .and_return("http://localhost:2080/imports/#{key}/")

      web_dav_service.url(key)
    end
  end
end
