import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { GymnastDetail } from '../types';
import { fetchGymnast, refreshGymnast } from '../api/client';
import PersonalBestsCard from '../components/PersonalBestsCard';
import ScoreTable from '../components/ScoreTable';
import ScoreChart from '../components/ScoreChart';

export default function GymnastPage() {
  const { id } = useParams<{ id: string }>();
  const [gymnast, setGymnast] = useState<GymnastDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedLevel, setSelectedLevel] = useState<number | 'all'>('all');

  const loadGymnast = async () => {
    if (!id) return;
    try {
      const data = await fetchGymnast(parseInt(id));
      setGymnast(data);
      setError(null);

      const levels = Object.keys(data.scores_by_level).map(Number);
      if (levels.length > 0 && selectedLevel === 'all') {
        setSelectedLevel(Math.max(...levels));
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load gymnast');
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = async () => {
    if (!id) return;
    setRefreshing(true);
    try {
      await refreshGymnast(parseInt(id));
      await loadGymnast();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to refresh');
    } finally {
      setRefreshing(false);
    }
  };

  useEffect(() => {
    loadGymnast();
  }, [id]);

  if (loading) {
    return (
      <div className="text-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
        <p className="mt-4 text-gray-500">Loading gymnast...</p>
      </div>
    );
  }

  if (error || !gymnast) {
    return (
      <div className="space-y-4">
        <Link to="/" className="text-primary-600 hover:text-primary-700">
          ← Back to Dashboard
        </Link>
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <p className="text-red-700">{error || 'Gymnast not found'}</p>
        </div>
      </div>
    );
  }

  const levels = Object.keys(gymnast.scores_by_level).map(Number).sort((a, b) => b - a);
  const displayScores =
    selectedLevel === 'all'
      ? gymnast.scores
      : gymnast.scores_by_level[selectedLevel] || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Link to="/" className="text-primary-600 hover:text-primary-700">
          ← Back to Dashboard
        </Link>
        <button
          onClick={handleRefresh}
          disabled={refreshing}
          className="px-4 py-2 text-sm bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 transition-colors"
        >
          {refreshing ? 'Refreshing...' : 'Refresh Scores'}
        </button>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">{gymnast.name}</h1>
            <p className="text-lg text-gray-600">{gymnast.team}</p>
          </div>
          {gymnast.source_url && (
            <a
              href={gymnast.source_url}
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm text-primary-600 hover:text-primary-700"
            >
              View on MyMeetScores →
            </a>
          )}
        </div>
      </div>

      <PersonalBestsCard personalBests={gymnast.personal_bests} />

      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold">Score Progress</h2>
            <div className="flex gap-2">
              <button
                onClick={() => setSelectedLevel('all')}
                className={`px-3 py-1 text-sm rounded-full transition-colors ${
                  selectedLevel === 'all'
                    ? 'bg-primary-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                All
              </button>
              {levels.map((level) => (
                <button
                  key={level}
                  onClick={() => setSelectedLevel(level)}
                  className={`px-3 py-1 text-sm rounded-full transition-colors ${
                    selectedLevel === level
                      ? 'bg-primary-600 text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  Level {level}
                </button>
              ))}
            </div>
          </div>
        </div>
        <div className="p-6">
          <ScoreChart
            scores={displayScores}
            title={selectedLevel === 'all' ? undefined : `Level ${selectedLevel} Progress`}
          />
        </div>
      </div>

      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold">
            Meet History {selectedLevel !== 'all' && `(Level ${selectedLevel})`}
          </h2>
        </div>
        <ScoreTable scores={displayScores} />
      </div>
    </div>
  );
}
