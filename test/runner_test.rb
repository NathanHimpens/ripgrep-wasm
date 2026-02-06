# frozen_string_literal: true

require_relative 'test_helper'
require 'open3'

class RunnerTest < Minitest::Test
  include RipgrepWasmTestHelper

  def test_raises_binary_not_found_when_binary_missing
    RipgrepWasm.binary_path = '/tmp/nonexistent/rg.wasm'

    assert_raises(RipgrepWasm::BinaryNotFound) do
      RipgrepWasm::Runner.run('pattern', 'file.txt')
    end
  end

  def test_builds_correct_command_array
    Dir.mktmpdir do |dir|
      binary = File.join(dir, 'rg.wasm')
      File.write(binary, 'fake')
      RipgrepWasm.binary_path = binary

      captured_cmd = nil
      fake_capture3 = lambda do |*cmd|
        captured_cmd = cmd
        status = Minitest::Mock.new
        status.expect(:success?, true)
        ['match output', '', status]
      end

      Open3.stub(:capture3, fake_capture3) do
        RipgrepWasm::Runner.run('-i', 'pattern', 'file.txt', wasm_dir: '/search')
      end

      assert_equal 'wasmtime', captured_cmd[0]
      assert_equal 'run', captured_cmd[1]
      assert_equal '--dir', captured_cmd[2]
      assert_equal '/search', captured_cmd[3]
      assert_equal binary, captured_cmd[4]
      assert_equal ['-i', 'pattern', 'file.txt'], captured_cmd[5..]
    end
  end

  def test_uses_configured_runtime
    Dir.mktmpdir do |dir|
      binary = File.join(dir, 'rg.wasm')
      File.write(binary, 'fake')
      RipgrepWasm.binary_path = binary
      RipgrepWasm.runtime = 'wazero'

      captured_cmd = nil
      fake_capture3 = lambda do |*cmd|
        captured_cmd = cmd
        status = Minitest::Mock.new
        status.expect(:success?, true)
        ['', '', status]
      end

      Open3.stub(:capture3, fake_capture3) do
        RipgrepWasm::Runner.run('pattern')
      end

      assert_equal 'wazero', captured_cmd[0]
    end
  end

  def test_returns_success_hash
    Dir.mktmpdir do |dir|
      binary = File.join(dir, 'rg.wasm')
      File.write(binary, 'fake')
      RipgrepWasm.binary_path = binary

      fake_capture3 = lambda do |*_cmd|
        status = Minitest::Mock.new
        status.expect(:success?, true)
        ['found: line 1', 'some warning', status]
      end

      Open3.stub(:capture3, fake_capture3) do
        result = RipgrepWasm::Runner.run('pattern', 'file.txt')
        assert_equal 'found: line 1', result[:stdout]
        assert_equal 'some warning', result[:stderr]
        assert_equal true, result[:success]
      end
    end
  end

  def test_raises_execution_error_on_failure
    Dir.mktmpdir do |dir|
      binary = File.join(dir, 'rg.wasm')
      File.write(binary, 'fake')
      RipgrepWasm.binary_path = binary

      fake_capture3 = lambda do |*_cmd|
        status = Minitest::Mock.new
        status.expect(:success?, false)
        status.expect(:exitstatus, 1)
        ['', 'error: something went wrong', status]
      end

      Open3.stub(:capture3, fake_capture3) do
        err = assert_raises(RipgrepWasm::ExecutionError) do
          RipgrepWasm::Runner.run('pattern', 'file.txt')
        end
        assert_includes err.message, 'error: something went wrong'
        assert_includes err.message, '1'
      end
    end
  end

  def test_defaults_wasm_dir_to_dot
    Dir.mktmpdir do |dir|
      binary = File.join(dir, 'rg.wasm')
      File.write(binary, 'fake')
      RipgrepWasm.binary_path = binary

      captured_cmd = nil
      fake_capture3 = lambda do |*cmd|
        captured_cmd = cmd
        status = Minitest::Mock.new
        status.expect(:success?, true)
        ['', '', status]
      end

      Open3.stub(:capture3, fake_capture3) do
        RipgrepWasm::Runner.run('pattern')
      end

      assert_equal '.', captured_cmd[3]
    end
  end
end
