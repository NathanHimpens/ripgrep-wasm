# frozen_string_literal: true

require_relative 'test_helper'

class RipgrepWasmTest < Minitest::Test
  include RipgrepWasmTestHelper

  def test_binary_path_returns_default_when_not_configured
    assert_match %r{lib/ripgrep_wasm/rg\.wasm\z}, RipgrepWasm.binary_path
  end

  def test_binary_path_setter_overrides_path
    RipgrepWasm.binary_path = '/tmp/custom/rg.wasm'
    assert_equal '/tmp/custom/rg.wasm', RipgrepWasm.binary_path
  end

  def test_runtime_returns_wasmtime_by_default
    assert_equal 'wasmtime', RipgrepWasm.runtime
  end

  def test_runtime_setter_overrides_runtime
    RipgrepWasm.runtime = 'wasmer'
    assert_equal 'wasmer', RipgrepWasm.runtime
  end

  def test_available_returns_false_when_binary_missing
    RipgrepWasm.binary_path = '/tmp/nonexistent/rg.wasm'
    refute RipgrepWasm.available?
  end

  def test_available_returns_true_when_binary_exists
    Dir.mktmpdir do |dir|
      binary = File.join(dir, 'rg.wasm')
      File.write(binary, 'fake')
      RipgrepWasm.binary_path = binary
      assert RipgrepWasm.available?
    end
  end

  def test_error_class_hierarchy
    assert RipgrepWasm::BinaryNotFound < RipgrepWasm::Error
    assert RipgrepWasm::ExecutionError < RipgrepWasm::Error
    assert RipgrepWasm::Error < StandardError
  end

  def test_version_matches_semver
    assert_match(/\A\d+\.\d+\.\d+\z/, RipgrepWasm::VERSION)
  end

  def test_download_to_binary_path_delegates_to_downloader
    called_with = nil
    fake_download = lambda { |to:| called_with = to; true }

    RipgrepWasm::Downloader.stub(:download, fake_download) do
      result = RipgrepWasm.download_to_binary_path!
      assert_equal true, result
      assert_equal RipgrepWasm.binary_path, called_with
    end
  end

  def test_run_delegates_to_runner
    captured_args = nil
    captured_kwargs = nil
    fake_run = lambda { |*args, **kwargs|
      captured_args = args
      captured_kwargs = kwargs
      { stdout: 'ok', stderr: '', success: true }
    }

    RipgrepWasm::Runner.stub(:run, fake_run) do
      result = RipgrepWasm.run('-i', 'pattern', 'file.txt', wasm_dir: '/tmp')
      assert_equal({ stdout: 'ok', stderr: '', success: true }, result)
      assert_equal ['-i', 'pattern', 'file.txt'], captured_args
      assert_equal({ wasm_dir: '/tmp' }, captured_kwargs)
    end
  end
end
