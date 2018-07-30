require 'net/dav'
#require 'webmock/rspec'
require 'rubygems'
require 'rack_dav'

RSpec.describe ActiveStorage::Service::WebDAVService do
  before do
    RackDAV::Handler.new(:root => '/spec/tmp/')
  end

  let(:webdav) { Net::DAV.new(URI.join('http://localhost/')) }
  let(:web_dav_service) do
    described_class.new( {
      url: '/spec/tmp/',
      net_dav: webdav
    } )
  end

  let(:key) { 'some-resource-key' }
  let(:checksum) { Digest::MD5.base64digest(key) }
  let(:io) { File.open(File.join('spec', 'fixtures', 'file.txt')) }
  #let(:file_path) { URI.join('http://localhost/import/', key) }
  let(:file_path) { '/spec/tmp/' }

  describe '#upload' do
    it 'saves file' do
      #aswd.put(file, ...)
      web_dav_service.upload(key, io, checksum: checksum)
      expect(File.exists?(file_path)).to be true
    end

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
      stub_request(:delete, 'http://localhost/import/some-resource-key')
        .with(headers: {
          'Accept': '*/*',
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type': 'text/xml; charset="utf-8"',
          'User-Agent': 'Ruby'
        }).to_return(status: 200, body: '', headers: {})
      web_dav_service.delete(key)

      stub_request(:propfind, 'http://localhost/import/some-resource-key')
        .with(
          body: '<?xml version=\"1.0\" encoding=\"utf-8\"?><DAV:propfind xmlns:DAV=\"DAV:\"><DAV:allprop/></DAV:propfind>',
          headers: {
            'Accept': '*/*',
            'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type': 'text/xml; charset="utf-8"',
            'Depth': '1',
            'User-Agent': 'Ruby'})
        .to_return(status: 200, body: '', headers: {})
    end

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:delete, {key: key})

      web_dav_service.delete(key)
    end
  end

  describe '#delete_prefixed' do
    let(:prefix) { 'prefix' }
    let(:first_file_path) { URI.join('http://localhost/import/', 'prefix_first_file_key') }

    before do
      stub_request(:put, 'http://localhost/import/prefix_first_file_key')
        .with(body:  '12345', headers:  {
          'Accept': '*/*',
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Length': '5',
          'Content-Type': 'application/octet-stream',
          'User-Agent': 'Ruby'
        }).to_return(status:  200, body:  "", headers:  {})

      webdav.put(first_file_path, io, File.size(io))
    end

    it 'calls the delete_prefixed method on webdav with the given args' do
      stub_request(:delete, 'http://localhost/import/prefix_first_file_key')
        .with(headers: {
          'Accept': '*/*',
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type': 'text/xml; charset="utf-8"',
          'User-Agent': 'Ruby'
        }).to_return(status:  200, body:  "", headers:  {})
      web_dav_service.delete('prefix_first_file_key')

      stub_request(:propfind, 'http://localhost/import/prefix_first_file_key').
        with(
          body: '<?xml version=\"1.0\" encoding=\"utf-8\"?><DAV:propfind xmlns:DAV=\"DAV:\"><DAV:allprop/></DAV:propfind>',
          headers: {
            'Accept': '*/*',
            'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type': 'text/xml; charset="utf-8"',
            'Depth': '1',
            'User-Agent': 'Ruby'
          }).to_return(status: 200, body: "", headers: {})
      # expect(webdav.exists?(first_file_path)).to be false
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
    let(:range) { 0..3 }

    it 'calls the download_chunk method on webdav' do
      range_for_dav = "bytes=#{range.begin}-#{range.exclude_end? ? range.end - 1 : range.end}"
      expect(webdav).to receive(:get).with(file_path, 'Range' => range_for_dav)
      web_dav_service.download_chunk(key, range)
    end

    it 'instruments the operation' do
      expect_any_instance_of(ActiveStorage::Service)
        .to receive(:instrument).with(:download_chunk, {key: key, range: range})
      web_dav_service.download_chunk(key, range)
    end
  end

end
