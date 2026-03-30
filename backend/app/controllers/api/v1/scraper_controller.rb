class Api::V1::ScraperController < ApplicationController
  def create
    source = detect_source(params[:url])
    external_id = extract_id_from_url(params[:url], source) || params[:external_id]

    unless external_id
      return render json: { error: "Please provide a valid MyMeetScores or MeetScoresOnline URL" }, status: :unprocessable_entity
    end

    scraper = create_scraper(source, external_id)
    gymnast = scraper.sync_gymnast

    if gymnast
      render json: {
        message: "Successfully synced gymnast from #{source}",
        gymnast: {
          id: gymnast.id,
          name: gymnast.name,
          team: gymnast.team,
          scores_count: gymnast.scores.count
        }
      }, status: :created
    else
      render json: { error: "Failed to scrape gymnast data" }, status: :unprocessable_entity
    end
  end

  def refresh
    gymnast = Gymnast.find(params[:id])
    results = []

    # Refresh from MyMeetScores if we have that ID
    if gymnast.external_id && !gymnast.external_id.start_with?("mso_")
      scraper = MyMeetScoresScraper.new(gymnast.external_id)
      if scraper.sync_gymnast
        results << "MyMeetScores"
      end
    end

    # Refresh from MeetScoresOnline if we have that ID
    mso_id = gymnast.external_id&.start_with?("mso_") ? gymnast.external_id.sub("mso_", "") : nil
    if mso_id
      scraper = MeetScoresOnlineScraper.new(mso_id)
      if scraper.sync_gymnast
        results << "MeetScoresOnline"
      end
    end

    gymnast.reload

    if results.any?
      render json: {
        message: "Successfully refreshed from: #{results.join(', ')}",
        gymnast: {
          id: gymnast.id,
          name: gymnast.name,
          scores_count: gymnast.scores.count
        }
      }
    else
      render json: { error: "Failed to refresh gymnast data" }, status: :unprocessable_entity
    end
  end

  # Delete a bad score record
  def delete_score
    score = Score.find(params[:score_id])
    competition = score.competition
    score.destroy!
    
    # Clean up orphaned competition if no scores reference it
    if competition.scores.count == 0
      competition.destroy!
    end
    
    render json: { message: "Score deleted successfully" }
  end

  # Manually update a score (for fixing incomplete scrapes)
  def update_score
    score = Score.find(params[:score_id])
    
    allowed_params = params.permit(:vault, :vault_rank, :bars, :bars_rank, 
                                   :beam, :beam_rank, :floor, :floor_rank,
                                   :all_around, :all_around_rank)
    
    score.update!(allowed_params.to_h.compact)
    
    render json: {
      message: "Score updated successfully",
      score: {
        id: score.id,
        competition: score.competition.name,
        vault: score.vault,
        bars: score.bars,
        beam: score.beam,
        floor: score.floor,
        all_around: score.all_around
      }
    }
  end

  # Link a gymnast to their MeetScoresOnline profile
  def link_mso
    gymnast = Gymnast.find(params[:id])
    mso_url = params[:mso_url]
    mso_id = extract_mso_id(mso_url)

    unless mso_id
      return render json: { error: "Invalid MeetScoresOnline URL" }, status: :unprocessable_entity
    end

    scraper = MeetScoresOnlineScraper.new(mso_id)
    
    # Sync scores from MSO to existing gymnast
    data = scraper.scrape
    if data
      scraper.send(:sync_scores, gymnast, data[:scores])
      gymnast.reload

      render json: {
        message: "Successfully linked and synced from MeetScoresOnline",
        gymnast: {
          id: gymnast.id,
          name: gymnast.name,
          scores_count: gymnast.scores.count
        }
      }
    else
      render json: { error: "Failed to fetch data from MeetScoresOnline" }, status: :unprocessable_entity
    end
  end

  private

  def detect_source(url)
    return :mymeetscores unless url
    
    if url.include?("meetscoresonline.com")
      :meetscoresonline
    else
      :mymeetscores
    end
  end

  def create_scraper(source, external_id)
    case source
    when :meetscoresonline
      MeetScoresOnlineScraper.new(external_id)
    else
      MyMeetScoresScraper.new(external_id)
    end
  end

  def extract_id_from_url(url, source)
    return nil unless url

    case source
    when :meetscoresonline
      extract_mso_id(url)
    else
      match = url.match(/gymnastid=(\d+)/)
      match[1] if match
    end
  end

  def extract_mso_id(url)
    return nil unless url
    # Match patterns like /Athlete.MyScores/1027544 or /results/36588/1027544
    match = url.match(/(?:Athlete\.MyScores|results\/\d+)\/(\d+)/)
    match[1] if match
  end
end
