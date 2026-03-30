import { useState } from 'react';
import { scrapeGymnast } from '../api/client';

interface Props {
  onSuccess: () => void;
}

export default function AddGymnastForm({ onSuccess }: Props) {
  const [url, setUrl] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      await scrapeGymnast(url);
      setUrl('');
      onSuccess();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add gymnast');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow p-6">
      <h2 className="text-lg font-semibold mb-4">Add Gymnast</h2>
      <div className="flex gap-3">
        <input
          type="text"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          placeholder="MyMeetScores URL or gymnast ID"
          className="flex-1 rounded-md border border-gray-300 px-4 py-2 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          disabled={loading}
        />
        <button
          type="submit"
          disabled={loading || !url.trim()}
          className="px-6 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {loading ? 'Adding...' : 'Add'}
        </button>
      </div>
      {error && (
        <p className="mt-2 text-sm text-red-600">{error}</p>
      )}
      <p className="mt-2 text-sm text-gray-500">
        Paste a MyMeetScores profile URL like: https://mymeetscores.com/gymnast.pl?gymnastid=12345
      </p>
    </form>
  );
}
