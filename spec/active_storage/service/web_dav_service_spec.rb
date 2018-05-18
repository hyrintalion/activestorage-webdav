require 'net/dav'

RSpec.describe ActiveStorage::Service::WebDAVService do
  let(:webdav) { Net::DAV.new(URI.join('http://localhost/', 'imports/')) }
  let(:web_dav_service) { described_class.new( { url: 'http://localhost/imports/' }) }

  let(:key) { 'some-resource-key' }
  let(:checksum) { Digest::MD5.base64digest(key) }
  let(:io) { File.open(File.join('spec', 'fixtures', 'file.txt')) }
  let(:file_path) { URI.join('http://localhost/imports/', key) }

  before do
    expect(Net::DAV).to receive(:new).with('http://localhost/imports/').and_return(webdav)
  end

  describe '#upload' do
    it 'calls the upload method on the webdav with the given args' do
      expect(webdav).to receive(:put).with(file_path, io, File.size(io))
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
    it 'calls the delete method on webdav with the given args' do
      expect(webdav).to receive(:delete).with(file_path)
      web_dav_service.delete(key)
    end

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:delete, { key: key } )

      web_dav_service.delete(key)
    end
  end

  describe '#delete_prefixed' do
    let(:prefix) { 'prefix' }
    let(:first_file_key) { 'prefix_first_file_key' }
    let(:second_file_key) { 'prefix_second_file_key' }
    let(:third_file_key) { 'prefix_third_file_key' }

    # how to test this?
    it 'calls the delete_prefixed method on webdav with the given args' do
      # создать файлы
      web_dav_service.upload(first_file_key, io, checksum: Digest::MD5.base64digest(first_file_key))

      # проверить их наличие
      expect ( web_dav_service.exist?(first_file_key) ).to be false

      # удалить
      web_dav_service.delete_prefixed(prefix)
    end

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:delete_prefixed, {prefix: key})

      web_dav_service.delete_prefixed(key)
    end
  end

  describe '#exist?' do
    it 'calls the exist method on webdav with the given args' do
      expect(webdav).to receive(:exists?).with(file_path)
      web_dav_service.exist?(key)
    end

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:exist, { key: key } )

      web_dav_service.exist?(key)
    end
  end

  describe '#download' do
    block = proc { 'test' }

    it 'calls the download method on webdav without block' do
      expect(webdav).to receive(:get).with(file_path)
      web_dav_service.download(key)
    end

    it 'calls the download method on webdav with block' do
      expect(webdav).to receive(:get).with(file_path, &block)
      web_dav_service.download(key, &block)
    end

    it 'instruments the operation without block' do
      options = { key: key }
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:download, options)

      web_dav_service.download(key)
    end

    it 'instruments the operation with block' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:streaming_download, key: key)

      web_dav_service.download(key, &block)
    end
  end

  describe '#download_chunk' do
    # how to declare range?
    let(:range) { 'range' }

    it 'calls the download_chunk method on webdav' do
      expect(webdav).to receive(:start) do |dav|
        dav.get(file_path, 'Range' => "bytes=#{range.begin}-#{range.exclude_end? ? range.end - 1 : range.end}").body
      end.with(file_path)
      web_dav_service.download_chunk(key, range)
    end

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:download_chunk, {key: key, range: range })

      web_dav_service.download_chunk(key, range)
    end
  end

end
