# frozen_string_literal: true

require 'open3'

module RipgrepWasm
  class Runner
    # Run the WASM binary via the configured WASI runtime.
    #
    # @param args [Array<String>] arguments passed through to the binary
    # @param wasm_dir [String] directory to expose to the WASI sandbox (default ".")
    # @return [Hash] { stdout: String, stderr: String, success: Boolean }
    # @raise [BinaryNotFound] if the binary does not exist at binary_path
    # @raise [ExecutionError] if the runtime exits with non-zero status
    def self.run(*args, wasm_dir: '.')
      binary = RipgrepWasm.binary_path

      unless File.exist?(binary)
        raise BinaryNotFound, "WASM binary not found at #{binary}"
      end

      cmd = [
        RipgrepWasm.runtime,
        'run',
        '--dir', wasm_dir,
        binary,
        *args
      ]

      stdout, stderr, status = Open3.capture3(*cmd)

      unless status.success?
        raise ExecutionError, "Command exited with status #{status.exitstatus}: #{stderr}"
      end

      { stdout: stdout, stderr: stderr, success: true }
    end
  end
end
