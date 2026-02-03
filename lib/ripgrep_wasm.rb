# frozen_string_literal: true

require_relative 'ripgrep_wasm/version'
require_relative 'ripgrep_wasm/downloader'

module RipgrepWasm
  class Error < StandardError; end

  # Get the path to the rg.wasm binary
  #
  # @return [String] The absolute path to rg.wasm
  def self.path
    wasm_path = File.join(File.dirname(__FILE__), 'ripgrep_wasm', 'rg.wasm')
    
    # If the file doesn't exist, try to download it
    unless File.exist?(wasm_path)
      Downloader.download_if_needed
    end
    
    wasm_path
  end

  # Check if rg.wasm is available
  #
  # @return [Boolean] true if rg.wasm exists
  def self.available?
    File.exist?(path)
  end

  # Get the absolute path to rg.wasm
  #
  # @return [String] The absolute path to rg.wasm
  def self.absolute_path
    File.expand_path(path)
  end
end
