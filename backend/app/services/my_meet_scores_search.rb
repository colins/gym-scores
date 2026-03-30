class MyMeetScoresSearch
  BASE_URL = "https://www.mymeetscores.com"

  def initialize(query)
    @query = query
  end

  def search
    response = fetch_search_results
    return [] unless response.success?

    parse_search_results(response.body)
  end

  private

  def fetch_search_results
    HTTParty.get(search_url, headers: request_headers)
  end

  def search_url
    "#{BASE_URL}/results.pl?search=#{CGI.escape(@query)}"
  end

  def request_headers
    {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
      "Accept" => "text/html,application/xhtml+xml"
    }
  end

  def parse_search_results(html)
    doc = Nokogiri::HTML(html)
    results = []

    doc.css("a[href*='gymnast.pl?gymnastid=']").each do |link|
      href = link["href"]
      next unless href

      gymnast_id = extract_gymnast_id(href)
      next unless gymnast_id

      name = link.text.strip
      next if name.empty?

      team = extract_team_for_gymnast(link)

      results << {
        external_id: gymnast_id,
        name: format_name(name),
        team: team,
        source: "mymeetscores",
        url: "#{BASE_URL}/gymnast.pl?gymnastid=#{gymnast_id}"
      }
    end

    results.uniq { |r| r[:external_id] }
  end

  def extract_gymnast_id(href)
    match = href.match(/gymnastid=(\d+)/)
    match[1] if match
  end

  def extract_team_for_gymnast(link)
    row = link.ancestors("tr").first
    return nil unless row

    team_link = row.at_css("a[href*='team.pl']")
    team_link&.text&.strip
  end

  def format_name(name)
    if name.match?(/^[A-Za-z'-]+,\s+[A-Za-z'-]+$/)
      parts = name.split(",", 2).map(&:strip)
      "#{parts[1]} #{parts[0]}"
    else
      name
    end
  end
end
