# frozen_string_literal: true

require_relative 'ripgrep_wasm/version'
require_relative 'ripgrep_wasm/downloader'
require_relative 'ripgrep_wasm/runner'

module RipgrepWasm
  class Error < StandardError; end
  class BinaryNotFound < Error; end
  class ExecutionError < Error; end

  DEFAULT_BINARY_PATH = File.join(File.dirname(__FILE__), 'ripgrep_wasm', 'rg.wasm').freeze

  class << self
    attr_writer :binary_path, :runtime

    def binary_path
      @binary_path || DEFAULT_BINARY_PATH
    end

    def runtime
      @runtime || 'wasmtime'
    end

    def download_to_binary_path!
      Downloader.download(to: binary_path)
    end

    def run(*args, wasm_dir: '.')
      Runner.run(*args, wasm_dir: wasm_dir)
    end

    def available?
      File.exist?(binary_path)
    end
  end
end
