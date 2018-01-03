class HackneyWardFinder
  def initialize(postcode)
    @postcode = postcode
  end

  def lookup
    return nil unless in_hackney?
    ward_from(response)
  end
  
  def in_hackney?
    borough_from(response).present?
  end

  private
  
  def response
    return if @postcode.blank? || GoingPostal.postcode?(@postcode, 'GB').blank?
    @response ||= HTTParty.get(url, headers: { 'ContentType' => 'application/json' }).parsed_response
  end
  
  def url
    "https://mapit.mysociety.org/postcode/#{@postcode.gsub(/\s+/, '')}"
  end

  def borough_from(response)
    response['areas']&.select { |area| response['areas'][area]['type'] == 'LBO' && response['areas'][area]['id'] == 2508 }
  end

  def ward_from(response)
    response['areas'].select { |area| response['areas'][area]['type'] == 'LBW' }.keys[0]
  end
end
