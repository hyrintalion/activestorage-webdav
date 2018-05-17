RSpec.describe ActiveStorage::Service::WebDAVService do
  let!(:webdav) { Net::DAV.new(URI.join('http://localhost/', 'imports')) }
  let!(:web_dav_service) { described_class.new(config) }

  let(:key) { 'some-resource-key' }
  let(:io) { File.open(File.join('spec', 'fixtures', 'file.txt')) }
  let(:checksum) { 'checksum' }
  let(:file_path) { URI.join('http://localhost/', 'imports', key) }
  let(:config) do
    {
      url: 'http://localhost/',
      path: 'imports'
    }
  end

  describe '#upload' do
    it 'calls the upload method on the webdav with the given args' do
      expect(webdav).to receive(:put).with(file_path, io, File.size(io))

      # NoMethodError: undefined method `third' for ["ActiveStorage", "Service", "WebDAVService"]:Array
      #  what?
      web_dav_service.upload(key, io, checksum: checksum)
    end

    it 'instruments the operation' do
      options = { key: key, checksum: checksum }
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:upload, options)

      web_dav_service.upload(key, io, checksum: checksum)
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

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:url, key: key)

      web_dav_service.url(key, options)
    end
  end

  describe '#url_for_direct_upload' do
    let(:options) do
      {
        expires_in: 1000,
        content_type: 'image/png',
        content_length: 123456789,
        checksum: checksum
      }
    end

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:url, key: key)

      web_dav_service.url_for_direct_upload(key, options)
    end
  end

  describe '#delete' do
    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
          .to receive(:instrument).with(:delete, { key: key })

      web_dav_service.delete(key)
    end
  end

  describe '#delete_prefixed' do
    let(:prefix) { 'some-key-prefix' }

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
          .to receive(:instrument).with(:delete_prefixed, { prefix: key })

      web_dav_service.delete_prefixed(key)
    end
  end

  describe '#exist?' do

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:exist, { key: key } )

      web_dav_service.exist?(key)
    end
  end

  describe '#download' do
    it 'instruments the operation without block' do
      options = { key: key }
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:download, options)

      web_dav_service.download(key)
    end

    it 'instruments the operation with block' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:streaming_download, key: key)

      web_dav_service.download(key) do
        'test'
      end
    end
  end

  describe '#download_chunk' do
    let(:range) { 'range' }
    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:download_chunk, { key: key, range: range })

      web_dav_service.download_chunk(key, range)
    end
  end

end
