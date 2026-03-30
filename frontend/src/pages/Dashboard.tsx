import { useState, useEffect } from 'react';
import { Gymnast } from '../types';
import { fetchGymnasts } from '../api/client';
import AddGymnastForm from '../components/AddGymnastForm';
import GymnastCard from '../components/GymnastCard';

export default function Dashboard() {
  const [gymnasts, setGymnasts] = useState<Gymnast[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadGymnasts = async () => {
    try {
      const data = await fetchGymnasts();
      setGymnasts(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load gymnasts');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadGymnasts();
  }, []);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-2 text-gray-600">
          Track gymnastics scores and progress across competitions
        </p>
      </div>

      <AddGymnastForm onSuccess={loadGymnasts} />

      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-500">Loading gymnasts...</p>
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <p className="text-red-700">{error}</p>
        </div>
      ) : gymnasts.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg shadow">
          <span className="text-6xl">🤸‍♀️</span>
          <h3 className="mt-4 text-lg font-medium text-gray-900">No gymnasts yet</h3>
          <p className="mt-2 text-gray-500">
            Add a gymnast using their MyMeetScores profile URL above
          </p>
        </div>
      ) : (
        <div>
          <h2 className="text-xl font-semibold text-gray-900 mb-4">
            Your Gymnasts ({gymnasts.length})
          </h2>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {gymnasts.map((gymnast) => (
              <GymnastCard key={gymnast.id} gymnast={gymnast} />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
