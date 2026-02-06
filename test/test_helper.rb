# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/ripgrep_wasm'

module RipgrepWasmTestHelper
  def setup
    @original_binary_path = RipgrepWasm.instance_variable_get(:@binary_path)
    @original_runtime     = RipgrepWasm.instance_variable_get(:@runtime)
  end

  def teardown
    RipgrepWasm.instance_variable_set(:@binary_path, @original_binary_path)
    RipgrepWasm.instance_variable_set(:@runtime,     @original_runtime)
  end
end
