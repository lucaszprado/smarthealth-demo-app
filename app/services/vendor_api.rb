require 'net/http'
require 'uri'

class VendorApi

  PID_MALE = ENV['ORNAMENT_MALE_ID']
  PID_FEMALE = ENV['ORNAMENT_FEMALE_ID']

  VENDOR_URL_MALE = "https://api.ornament.health/medical-data-api/public/v1.0/profile/biomarkers?pid=#{PID_MALE}"
  VENDOR_URL_FEMALE = "https://api.ornament.health/medical-data-api/public/v1.0/profile/biomarkers?pid=#{PID_FEMALE}"


  def self.get_parsed_data(gender)
    if gender == "M"
      uri = URI.parse(VENDOR_URL_MALE)
    else
      uri = URI.parse(VENDOR_URL_FEMALE)
    end

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
