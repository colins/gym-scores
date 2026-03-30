class Api::V1::GymnastsController < ApplicationController
  def index
    @gymnasts = Gymnast.includes(:scores).all
    render json: @gymnasts.map { |g| gymnast_summary(g) }
  end

  def show
    @gymnast = Gymnast.includes(scores: :competition).find(params[:id])
    render json: gymnast_detail(@gymnast)
  end

  private

  def gymnast_summary(gymnast)
    {
      id: gymnast.id,
      name: gymnast.name,
      team: gymnast.team,
      external_id: gymnast.external_id,
      scores_count: gymnast.scores.count,
      latest_level: gymnast.scores.order(created_at: :desc).first&.level
    }
  end

  def gymnast_detail(gymnast)
    scores_by_level = gymnast.scores.by_date.group_by(&:level)

    {
      id: gymnast.id,
      name: gymnast.name,
      team: gymnast.team,
      external_id: gymnast.external_id,
      source_url: gymnast.source_url,
      personal_bests: calculate_personal_bests(gymnast.scores),
      scores: gymnast.scores.by_date.map { |s| score_json(s) },
      scores_by_level: scores_by_level.transform_values { |scores| scores.map { |s| score_json(s) } }
    }
  end

  def calculate_personal_bests(scores)
    scores.group_by(&:level).transform_values do |level_scores|
      {
        vault: level_scores.map(&:vault).compact.max,
        bars: level_scores.map(&:bars).compact.max,
        beam: level_scores.map(&:beam).compact.max,
        floor: level_scores.map(&:floor).compact.max,
        all_around: level_scores.map(&:all_around).compact.max
      }
    end
  end

  def score_json(score)
    {
      id: score.id,
      competition: {
        id: score.competition.id,
        name: score.competition.name,
        date: score.competition.date
      },
      level: score.level,
      division: score.division,
      session: score.session,
      vault: score.vault&.to_f,
      vault_rank: score.vault_rank,
      bars: score.bars&.to_f,
      bars_rank: score.bars_rank,
      beam: score.beam&.to_f,
      beam_rank: score.beam_rank,
      floor: score.floor&.to_f,
      floor_rank: score.floor_rank,
      all_around: score.all_around&.to_f,
      all_around_rank: score.all_around_rank
    }
  end
end
