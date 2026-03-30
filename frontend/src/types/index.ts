export interface Gymnast {
  id: number;
  name: string;
  team: string;
  external_id: string;
  source_url?: string;
  scores_count?: number;
  latest_level?: number;
}

export interface Competition {
  id: number;
  name: string;
  date: string;
}

export interface Score {
  id: number;
  competition: Competition;
  level: number;
  division: string;
  session: string;
  vault: number | null;
  vault_rank: number | null;
  bars: number | null;
  bars_rank: number | null;
  beam: number | null;
  beam_rank: number | null;
  floor: number | null;
  floor_rank: number | null;
  all_around: number | null;
  all_around_rank: number | null;
}

export interface PersonalBests {
  [level: string]: {
    vault: number | string | null;
    bars: number | string | null;
    beam: number | string | null;
    floor: number | string | null;
    all_around: number | string | null;
  };
}

export interface GymnastDetail extends Gymnast {
  personal_bests: PersonalBests;
  scores: Score[];
  scores_by_level: { [level: number]: Score[] };
}

export interface SearchResult {
  external_id: string;
  name: string;
  team: string | null;
  source: string;
  url: string;
}
