RSpec.describe ActiveStorage::Service::WebDAVService do
  let(:key) { 'some-resource-key' }
  let(:file) { 'some-io-object' }

  subject(:web_dav_service) { described_class.new(url: "http://localhost/imports/") }

  describe '#upload' do
    it 'загрузка файла' do
      expect(web_dav_service).to receive(:upload).with(file, public_id: key)

      web_dav_service.upload(file, {:public_id=>key})
    end
  end

end
