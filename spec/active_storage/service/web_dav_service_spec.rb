RSpec.describe ActiveStorage::Service::WebDAVService do
  let(:key) { 'some-resource-key' }
  let(:file) { 'some-io-object' }

  let(:web_dav_service) { described_class.new(url: "http://localhost:2080/imports/") }

  describe '#upload' do
    it 'загрузка файла' do
      expect(web_dav_service).to receive(:upload).with(file, public_id: key)

      web_dav_service.upload(file, {:public_id=>key})
    end
  end

  describe '#url' do
    let(:options) do
      {
        expires_in: 1000,
        disposition: 'inline',
        filename: 'some-file-name',
        content_type: 'image/png'
      }
    end
    let(:signed_options) do
      {
        resource_type: 'image',
        type: 'upload',
        attachment: false
      }
    end

    it 'получение урл' do
      #expect(web_dav_service)
      #  .to receive(:url)
      #  .with(key, nil, signed_options)

      #web_dav_service.url(key, options)
    end

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:url, key: key)

      web_dav_service.url(key, options)
    end

  end
end
