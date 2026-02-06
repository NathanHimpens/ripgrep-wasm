# frozen_string_literal: true

require_relative 'test_helper'
require 'open3'

class IntegrationTest < Minitest::Test
  include RipgrepWasmTestHelper

  def test_full_user_workflow
    Dir.mktmpdir do |dir|
      target = File.join(dir, 'rg.wasm')

      # 1. Configure
      RipgrepWasm.binary_path = target
      RipgrepWasm.runtime = 'wazero'

      # 2. Not available yet
      refute RipgrepWasm.available?

      # 3. Download (stub writes fake file)
      RipgrepWasm::Downloader.stub(:download, ->(to:) { File.write(to, 'fake'); true }) do
        RipgrepWasm.download_to_binary_path!
      end

      # 4. Now available
      assert RipgrepWasm.available?

      # 5. Run (stub Open3, capture command)
      captured_cmd = nil
      fake_capture3 = lambda do |*cmd|
        captured_cmd = cmd
        status = Minitest::Mock.new
        status.expect(:success?, true)
        ['search results', '', status]
      end

      Open3.stub(:capture3, fake_capture3) do
        result = RipgrepWasm.run('-i', 'pattern', 'src/', wasm_dir: dir)
        assert result[:success]
        assert_equal 'search results', result[:stdout]
      end

      # 6. Verify command shape
      assert_equal 'wazero', captured_cmd[0]
      assert_equal 'run', captured_cmd[1]
      assert_equal '--dir', captured_cmd[2]
      assert_equal dir, captured_cmd[3]
      assert_equal target, captured_cmd[4]
      assert_equal ['-i', 'pattern', 'src/'], captured_cmd[5..]
    end
  end

  def test_run_before_download_raises_binary_not_found
    Dir.mktmpdir do |dir|
      RipgrepWasm.binary_path = File.join(dir, 'rg.wasm')
      assert_raises(RipgrepWasm::BinaryNotFound) do
        RipgrepWasm.run('-i', 'pattern', 'file.txt', wasm_dir: dir)
      end
    end
  end
end
