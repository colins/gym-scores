class MeetScoresOnlineScraper
  BASE_URL = "https://meetscoresonline.com"

  def initialize(athlete_id)
    @athlete_id = athlete_id
  end

  def scrape
    response = fetch_athlete_page
    return nil unless response.success?

    parse_athlete_page(response.body)
  end

  def sync_gymnast
    data = scrape
    return nil unless data

    gymnast = find_or_create_gymnast(data)
    sync_scores(gymnast, data[:scores])
    gymnast.reload
  end

  private

  def fetch_athlete_page
    HTTParty.get(athlete_url, headers: request_headers)
  end

  def athlete_url
    "#{BASE_URL}/Athlete.MyScores/#{@athlete_id}"
  end

  def request_headers
    {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
      "Accept" => "text/html,application/xhtml+xml"
    }
  end

  def parse_athlete_page(html)
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
    # Name is in h1 tag or profile header
    h1 = doc.at_css("h1")
    return h1.text.strip if h1 && h1.text.strip.length < 50

    # Fallback: look for profile name pattern
    doc.css(".profile-name, .athlete-name").each do |el|
      text = el.text.strip
      return text if text.length > 0 && text.length < 50
    end

    nil
  end

  def extract_team(doc)
    # Team often appears near name or in profile info
    doc.css("td, span, div").each do |el|
      text = el.text.strip
      # Look for team patterns - usually short text after "Team:" or standalone
      if text.match?(/^(Team|Club):\s*(.+)/i)
        return $2.strip
      end
    end

    # Look in table cells for team info
    doc.css("table tr").each do |row|
      cells = row.css("td")
      cells.each_with_index do |cell, i|
        if cell.text.strip.downcase == "team" && cells[i + 1]
          return cells[i + 1].text.strip
        end
      end
    end

    nil
  end

  def extract_scores(doc)
    scores = []

    # MeetScoresOnline has scores in table rows with this pattern:
    # Meet Name | Team | Level Division | AA Score
    # Then a sub-row with: Vault X.XXX rank | Bars X.XXX rank | Beam X.XXX rank | Floor X.XXX rank
    
    doc.css("table tr").each do |row|
      text = row.text
      
      # Look for rows containing meet result patterns
      # Pattern: has a link to results AND contains score-like numbers
      meet_link = row.at_css("a[href*='/results/'], a[href*='/R']")
      next unless meet_link
      
      meet_name = meet_link.text.strip
      meet_url = meet_link["href"]
      meet_id = extract_meet_id(meet_url)
      
      # Extract level and division from the row
      # Pattern like "7 Sr B" or "Level 7 Middle"
      level_match = text.match(/\b(\d)\s+([A-Za-z][A-Za-z\s\.]+?)(?:\s*\d|$|\]|\|)/)
      next unless level_match
      
      level = level_match[1].to_i
      division = level_match[2].strip
      
      # Extract AA score - usually the last big number with a rank
      aa_match = text.match(/(\d{2}\.\d+)\s*(\d+T?)?\s*$/)
      
      # Extract individual event scores
      # Pattern: "Vault 9.0500 3" or "VT 9.050 3"
      vault_match = text.match(/(?:Vault|VT)\s*(\d+\.\d+)\s*(\d+T?)?/i)
      bars_match = text.match(/(?:Bars|UB)\s*(\d+\.\d+)\s*(\d+T?)?/i)
      beam_match = text.match(/(?:Beam|BB)\s*(\d+\.\d+)\s*(\d+T?)?/i)
      floor_match = text.match(/(?:Floor|FX)\s*(\d+\.\d+)\s*(\d+T?)?/i)
      
      # Also check the next sibling row for score details
      next_row = row.next_element
      if next_row && next_row.name == "tr"
        next_text = next_row.text
        vault_match ||= next_text.match(/(?:Vault|VT)\s*(\d+\.\d+)\s*(\d+T?)?/i)
        bars_match ||= next_text.match(/(?:Bars|UB)\s*(\d+\.\d+)\s*(\d+T?)?/i)
        beam_match ||= next_text.match(/(?:Beam|BB)\s*(\d+\.\d+)\s*(\d+T?)?/i)
        floor_match ||= next_text.match(/(?:Floor|FX)\s*(\d+\.\d+)\s*(\d+T?)?/i)
        aa_match ||= next_text.match(/(?:AA)\s*(\d{2}\.\d+)\s*(\d+T?)?/i)
      end
      
      # Need at least one event score
      next unless vault_match || bars_match || beam_match || floor_match || aa_match
      
      date = extract_date_from_row(row, meet_name)
      
      scores << {
        date: date,
        meet_name: meet_name,
        meet_id: meet_id,
        meet_url: meet_url ? normalize_url(meet_url) : nil,
        level: level,
        division: division,
        session: "",
        vault: vault_match ? vault_match[1].to_f : nil,
        vault_rank: vault_match ? vault_match[2]&.gsub("T", "")&.to_i : nil,
        bars: bars_match ? bars_match[1].to_f : nil,
        bars_rank: bars_match ? bars_match[2]&.gsub("T", "")&.to_i : nil,
        beam: beam_match ? beam_match[1].to_f : nil,
        beam_rank: beam_match ? beam_match[2]&.gsub("T", "")&.to_i : nil,
        floor: floor_match ? floor_match[1].to_f : nil,
        floor_rank: floor_match ? floor_match[2]&.gsub("T", "")&.to_i : nil,
        all_around: aa_match ? aa_match[1].to_f : nil,
        all_around_rank: aa_match ? aa_match[2]&.gsub("T", "")&.to_i : nil
      }
    end

    scores
  end

  def extract_meet_id(url)
    return nil unless url
    # Match patterns like /results/36588 or /R36588
    match = url.match(/\/(?:results\/|R)(\d+)/)
    "mso_#{match[1]}" if match
  end

  def extract_date_from_row(row, meet_name)
    # Try to find date in the row
    row.css("td").each do |cell|
      text = cell.text.strip
      if text.match?(/\d{4}-\d{2}-\d{2}/)
        return Date.parse(text)
      elsif text.match?(/\d{1,2}\/\d{1,2}\/\d{4}/)
        return Date.strptime(text, "%m/%d/%Y")
      end
    end

    # Extract year from meet name if present
    if meet_name&.match?(/20\d{2}/)
      year = meet_name.match(/20\d{2}/)[0].to_i
      return Date.new(year, 1, 1)
    end

    Date.today
  end

  def normalize_url(url)
    return url if url.start_with?("http")
    "#{BASE_URL}#{url}"
  end

  def find_or_create_gymnast(data)
    # Try to find existing gymnast by name and team
    gymnast = Gymnast.find_by(
      "LOWER(name) = ? AND LOWER(team) = ?",
      data[:name]&.downcase,
      data[:team]&.downcase
    )

    if gymnast
      # Update with MSO source info if not already set
      gymnast.update!(
        mso_id: @athlete_id,
        mso_url: athlete_url
      ) if gymnast.respond_to?(:mso_id)
      return gymnast
    end

    # Create new gymnast
    Gymnast.create!(
      name: data[:name],
      team: data[:team],
      external_id: "mso_#{@athlete_id}",
      source_url: athlete_url
    )
  end

  def sync_scores(gymnast, scores_data)
    scores_data.each do |score_data|
      next unless score_data[:meet_name]

      competition = find_or_create_competition(score_data)

      score = Score.find_or_initialize_by(
        gymnast: gymnast,
        competition: competition,
        level: score_data[:level],
        division: score_data[:division]
      )

      # Update with new data (MSO might have more complete data)
      updates = {
        session: score_data[:session],
        vault: score_data[:vault] || score.vault,
        vault_rank: score_data[:vault_rank] || score.vault_rank,
        bars: score_data[:bars] || score.bars,
        bars_rank: score_data[:bars_rank] || score.bars_rank,
        beam: score_data[:beam] || score.beam,
        beam_rank: score_data[:beam_rank] || score.beam_rank,
        floor: score_data[:floor] || score.floor,
        floor_rank: score_data[:floor_rank] || score.floor_rank,
        all_around: score_data[:all_around] || score.all_around,
        all_around_rank: score_data[:all_around_rank] || score.all_around_rank
      }

      score.update!(updates)
    end
  end

  def find_or_create_competition(score_data)
    # Try to find by external_id first
    if score_data[:meet_id]
      comp = Competition.find_by(external_id: score_data[:meet_id])
      return comp if comp
    end

    # Try to find by name and date
    comp = Competition.find_by(
      "LOWER(name) = ? AND date = ?",
      score_data[:meet_name]&.downcase,
      score_data[:date]
    )
    return comp if comp

    # Create new competition
    Competition.create!(
      name: score_data[:meet_name],
      date: score_data[:date],
      external_id: score_data[:meet_id],
      source_url: score_data[:meet_url]
    )
  end
end
