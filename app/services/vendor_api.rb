require 'net/http'
require 'uri'

class VendorApi
  PID = '1a270e28-804a-44b8-8f09-3fa42b0e3975'
  # <attention> | LP @2024-09-30: I changed the PID FROM 7169a804-6e39-4ce3-a4b9-ff85cd8c058a TO
  # 58fffbc4-2824-4969-961a-0edc7741b247 in order to
  # link to the PID where we will upload and delete data all the time # We will not use # my personal account.
  # than I changed to '1a270e28-804a-44b8-8f09-3fa42b0e3975' to match healer's account.
  # Women PID: 3650b54e-1a82-400c-be9b-d625c2cb2ad2
  # Men PID: 1a270e28-804a-44b8-8f09-3fa42b0e3975
  VENDOR_URL = "https://api.ornament.health/medical-data-api/public/v1.0/profile/biomarkers?pid=#{PID}"


  def self.get_parsed_data()
    uri = URI.parse(VENDOR_URL)

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ENV['VENDOR_API_TOKEN']}"

    ## We will not use this right now because Lucas will upload the pdf manually. We will only get the response by API.
    # # Attach the PDF from ActiveStorage
    # file = source.file.download  # Download the file locally
    # form_data = [["pdf", file]]

    # request.set_form form_data, 'multipart/form-data'

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Assuming the response is JSON
    JSON.parse(response.body)
  rescue => e
    raise "Error sending PDF to vendor: #{e.message}"
  end
end
