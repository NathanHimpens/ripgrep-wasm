# frozen_string_literal: true

require 'net/http'
require 'json'
require 'fileutils'
require 'uri'

module RipgrepWasm
  class Downloader
    REPO_OWNER = 'NathanHimpens'
    REPO_NAME = 'ripgrep-wasm'
    ASSET_NAME = 'rg.wasm'

    # Download rg.wasm from the latest GitHub release.
    #
    # @param to [String] absolute path where the binary will be written
    # @return [true] on success
    # @raise [StandardError] on network or API errors
    def self.download(to:)
      target = File.expand_path(to)
      FileUtils.mkdir_p(File.dirname(target))

      begin
        tag = get_latest_release_tag
        download_asset(tag, target)
      rescue StandardError => e
        FileUtils.rm_f(target)
        warn "Error downloading rg.wasm: #{e.message}"
        raise
      end
    end

    private

    # Get the latest release tag from GitHub API
    def self.get_latest_release_tag
      uri = URI("https://api.github.com/repos/#{REPO_OWNER}/#{REPO_NAME}/releases/latest")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30

      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = 'ripgrep-wasm-ruby-downloader'
      request['Accept'] = 'application/vnd.github.v3+json'

      response = http.request(request)

      case response.code
      when '200'
        release = JSON.parse(response.body)
        release['tag_name']
      when '404'
        version = RipgrepWasm::VERSION
        "v#{version}"
      else
        raise "GitHub API returned status #{response.code}: #{response.body}"
      end
    end

    # Download the asset from GitHub Releases
    def self.download_asset(tag, target)
      uri = URI("https://api.github.com/repos/#{REPO_OWNER}/#{REPO_NAME}/releases/tags/#{tag}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30

      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = 'ripgrep-wasm-ruby-downloader'
      request['Accept'] = 'application/vnd.github.v3+json'

      response = http.request(request)

      case response.code
      when '200'
        # continue
      when '404'
        raise "Release #{tag} not found on GitHub"
      else
        raise "GitHub API returned status #{response.code}: #{response.body}"
      end

      release = JSON.parse(response.body)
      asset = release['assets'].find { |a| a['name'] == ASSET_NAME }

      unless asset
        raise "Asset #{ASSET_NAME} not found in release #{tag}"
      end

      download_uri = URI(asset['browser_download_url'])
      download_http = Net::HTTP.new(download_uri.host, download_uri.port)
      download_http.use_ssl = true
      download_http.read_timeout = 300

      download_request = Net::HTTP::Get.new(download_uri)
      download_request['User-Agent'] = 'ripgrep-wasm-ruby-downloader'
      download_request['Accept'] = 'application/octet-stream'

      File.open(target, 'wb') do |file|
        download_http.request(download_request) do |dl_response|
          case dl_response.code
          when '200'
            dl_response.read_body do |chunk|
              file.write(chunk)
            end
          else
            raise "Failed to download asset: #{dl_response.code}"
          end
        end
      end

      File.chmod(0o755, target)
      true
    end
  end
end
