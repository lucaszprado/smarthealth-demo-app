require 'net/http'
require 'uri'

class VendorApi
  PID = '7169a804-6e39-4ce3-a4b9-ff85cd8c058a'
  VENDOR_URL = "https://api.ornament.health/medical-data-api/public/v1.0/profile/biomarkers?pid=#{PID}"


  def self.send_pdf_to_vendor(source)
    uri = URI.parse(VENDOR_URL)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ENV['VENDOR_API_TOKEN']}"

    ## We will not use this right now because Lucas will upload the pdf manually. We will only get the response by API
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
