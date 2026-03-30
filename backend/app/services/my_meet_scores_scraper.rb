class MyMeetScoresScraper
  BASE_URL = "https://www.mymeetscores.com"

  def initialize(gymnast_id)
    @gymnast_id = gymnast_id
  end

  def scrape
    response = fetch_gymnast_page
    return nil unless response.success?

    parse_gymnast_page(response.body)
  end

  def sync_gymnast
    data = scrape
    return nil unless data

    gymnast = Gymnast.find_or_initialize_by(external_id: @gymnast_id)
    gymnast.update!(
      name: data[:name],
      team: data[:team],
      source_url: gymnast_url
    )

    sync_scores(gymnast, data[:scores])
    gymnast.reload
  end

  private

  def fetch_gymnast_page
    HTTParty.get(gymnast_url, headers: request_headers)
  end

  def gymnast_url
    "#{BASE_URL}/gymnast.pl?gymnastid=#{@gymnast_id}"
  end

  def request_headers
    {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
      "Accept" => "text/html,application/xhtml+xml"
    }
  end

  def parse_gymnast_page(html)
    doc = Nokogiri::HTML(html)

    name = extract_name(doc)
    team = extract_team(doc)
    scores = extract_scores(doc)

    {
      name: name,
      team: team,
      scores: scores
    }
  end

  def extract_name(doc)
    # Look for the gymnast name in a table cell that contains the team link
    # The name appears before the team link in the same cell
    team_link = doc.at_css("a[href*='team.pl']")
    if team_link
      # Navigate up to find the containing cell/row and extract name
      parent_cell = team_link.parent
      if parent_cell
        # Get text before the team link - the name is typically on its own line
        full_text = parent_cell.inner_html
        # Extract name from before the first <a> tag
        if full_text =~ /^([^<]+)/
          name = $1.strip
          return name unless name.empty?
        end
      end
    end

    # Fallback: look for large font text that looks like a name
    doc.css("td").each do |td|
      style = td["style"] || ""
      if style.include?("font-size") && style.include?("24")
        text = td.text.strip.split("\n").first&.strip
        return text if text && text.length < 100 && !text.include?("TOP")
      end
    end

    # Last resort: find text that appears before team name
    team_name = extract_team(doc)
    if team_name
      doc.css("td").each do |td|
        text = td.text
        if text.include?(team_name)
          lines = text.split("\n").map(&:strip).reject(&:empty?)
          team_index = lines.index { |l| l.include?(team_name) }
          if team_index && team_index > 0
            potential_name = lines[team_index - 1]
            return potential_name if potential_name.length < 100 && !potential_name.include?("TOP")
          end
        end
      end
    end

    nil
  end

  def extract_team(doc)
    team_link = doc.at_css("a[href*='team.pl']")
    team_link&.text&.strip
  end

  def extract_scores(doc)
    scores = []

    rows = doc.css("tr").select do |row|
      cells = row.css("td")
      cells.length >= 11 && cells[0].text.match?(/^\d{4}-\d{2}-\d{2}$/)
    end

    rows.each do |row|
      cells = row.css("td")
      score_data = parse_score_row(cells)
      scores << score_data if score_data
    end

    scores
  end

  def parse_score_row(cells)
    return nil if cells.length < 11

    date_text = cells[0].text.strip
    meet_link = cells[1].at_css("a")
    meet_name = meet_link&.text&.strip
    meet_url = meet_link&.[]("href")
    meet_id = extract_meet_id(meet_url)

    level_text = cells[4].text.strip
    level = level_text.to_i
    return nil if level == 0

    division = cells[5].text.strip
    session = cells[3].text.strip

    {
      date: Date.parse(date_text),
      meet_name: meet_name,
      meet_id: meet_id,
      meet_url: meet_url ? "#{BASE_URL}#{meet_url}" : nil,
      level: level,
      division: division,
      session: session,
      vault: parse_score_cell(cells[6]),
      vault_rank: parse_rank_cell(cells[6]),
      bars: parse_score_cell(cells[7]),
      bars_rank: parse_rank_cell(cells[7]),
      beam: parse_score_cell(cells[8]),
      beam_rank: parse_rank_cell(cells[8]),
      floor: parse_score_cell(cells[9]),
      floor_rank: parse_rank_cell(cells[9]),
      all_around: parse_score_cell(cells[10]),
      all_around_rank: parse_rank_cell(cells[10])
    }
  rescue ArgumentError
    nil
  end

  def extract_meet_id(url)
    return nil unless url
    match = url.match(/meetid=(\d+)/)
    match[1] if match
  end

  def parse_score_cell(cell)
    text = cell.text.strip
    score_match = text.match(/^(\d+\.\d+)/)
    return nil unless score_match
    BigDecimal(score_match[1])
  end

  def parse_rank_cell(cell)
    text = cell.text.strip
    rank_match = text.match(/(\d+)T?$/)
    return nil unless rank_match
    rank_match[1].to_i
  end

  def sync_scores(gymnast, scores_data)
    scores_data.each do |score_data|
      competition = find_or_create_competition(score_data)

      score = Score.find_or_initialize_by(
        gymnast: gymnast,
        competition: competition,
        level: score_data[:level],
        division: score_data[:division]
      )

      score.update!(
        session: score_data[:session],
        vault: score_data[:vault],
        vault_rank: score_data[:vault_rank],
        bars: score_data[:bars],
        bars_rank: score_data[:bars_rank],
        beam: score_data[:beam],
        beam_rank: score_data[:beam_rank],
        floor: score_data[:floor],
        floor_rank: score_data[:floor_rank],
        all_around: score_data[:all_around],
        all_around_rank: score_data[:all_around_rank]
      )
    end
  end

  def find_or_create_competition(score_data)
    Competition.find_or_create_by!(external_id: score_data[:meet_id]) do |comp|
      comp.name = score_data[:meet_name]
      comp.date = score_data[:date]
      comp.source_url = score_data[:meet_url]
    end
  end
end
