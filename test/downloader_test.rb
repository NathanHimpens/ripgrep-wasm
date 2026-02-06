# frozen_string_literal: true

require_relative 'test_helper'

class DownloaderTest < Minitest::Test
  include RipgrepWasmTestHelper

  def test_constants_defined
    assert_equal 'NathanHimpens', RipgrepWasm::Downloader::REPO_OWNER
    assert_equal 'ripgrep-wasm', RipgrepWasm::Downloader::REPO_NAME
    assert_equal 'rg.wasm', RipgrepWasm::Downloader::ASSET_NAME
  end

  def test_download_accepts_to_keyword
    method = RipgrepWasm::Downloader.method(:download)
    params = method.parameters
    assert_includes params, [:keyreq, :to]
  end

  def test_download_raises_on_network_error
    fake_get_tag = lambda { raise StandardError, 'connection refused' }

    Dir.mktmpdir do |dir|
      target = File.join(dir, 'rg.wasm')

      RipgrepWasm::Downloader.stub(:get_latest_release_tag, fake_get_tag) do
        assert_raises(StandardError) do
          RipgrepWasm::Downloader.download(to: target)
        end
        # Partial file should be cleaned up
        refute File.exist?(target)
      end
    end
  end

  def test_download_expands_target_path
    expanded_path = nil
    fake_get_tag = lambda { 'v1.0.0' }
    fake_download_asset = lambda { |_tag, target|
      expanded_path = target
      File.write(target, 'fake')
      true
    }

    Dir.mktmpdir do |dir|
      relative_path = File.join(dir, 'sub', '..', 'rg.wasm')

      RipgrepWasm::Downloader.stub(:get_latest_release_tag, fake_get_tag) do
        RipgrepWasm::Downloader.stub(:download_asset, fake_download_asset) do
          RipgrepWasm::Downloader.download(to: relative_path)
        end
      end

      assert_equal File.expand_path(relative_path), expanded_path
    end
  end

  def test_download_returns_true_on_success
    fake_get_tag = lambda { 'v1.0.0' }
    fake_download_asset = lambda { |_tag, target|
      File.write(target, 'fake')
      true
    }

    Dir.mktmpdir do |dir|
      target = File.join(dir, 'rg.wasm')

      result = nil
      RipgrepWasm::Downloader.stub(:get_latest_release_tag, fake_get_tag) do
        RipgrepWasm::Downloader.stub(:download_asset, fake_download_asset) do
          result = RipgrepWasm::Downloader.download(to: target)
        end
      end

      assert_equal true, result
    end
  end
end
