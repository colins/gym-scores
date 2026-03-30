import { useState, useEffect, useRef } from 'react';
import { scrapeGymnast, searchGymnasts } from '../api/client';
import { SearchResult } from '../types';

interface Props {
  onSuccess: () => void;
}

export default function AddGymnastForm({ onSuccess }: Props) {
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [showResults, setShowResults] = useState(false);
  const searchTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const isUrl = input.includes('http') || input.match(/^\d+$/);

  useEffect(() => {
    if (searchTimeout.current) {
      clearTimeout(searchTimeout.current);
    }

    if (!input.trim() || isUrl) {
      setSearchResults([]);
      setShowResults(false);
      return;
    }

    if (input.length < 2) {
      return;
    }

    searchTimeout.current = setTimeout(async () => {
      setSearching(true);
      try {
        const results = await searchGymnasts(input);
        setSearchResults(results);
        setShowResults(results.length > 0);
      } catch {
        setSearchResults([]);
      } finally {
        setSearching(false);
      }
    }, 300);

    return () => {
      if (searchTimeout.current) {
        clearTimeout(searchTimeout.current);
      }
    };
  }, [input, isUrl]);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setShowResults(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;
    
    await addGymnast(input);
  };

  const addGymnast = async (urlOrId: string) => {
    setLoading(true);
    setError(null);
    setShowResults(false);

    try {
      await scrapeGymnast(urlOrId);
      setInput('');
      setSearchResults([]);
      onSuccess();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add gymnast');
    } finally {
      setLoading(false);
    }
  };

  const handleSelectResult = (result: SearchResult) => {
    addGymnast(result.url);
  };

  return (
    <div ref={containerRef} className="bg-white rounded-lg shadow p-6">
      <h2 className="text-lg font-semibold mb-4">Add Gymnast</h2>
      <form onSubmit={handleSubmit}>
        <div className="flex gap-3">
          <div className="flex-1 relative">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onFocus={() => searchResults.length > 0 && setShowResults(true)}
              placeholder="Search by name or paste URL/ID"
              className="w-full rounded-md border border-gray-300 px-4 py-2 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              disabled={loading}
            />
            {searching && (
              <div className="absolute right-3 top-1/2 -translate-y-1/2">
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-primary-600"></div>
              </div>
            )}
            {showResults && searchResults.length > 0 && (
              <div className="absolute z-10 w-full mt-1 bg-white rounded-md shadow-lg border border-gray-200 max-h-64 overflow-y-auto">
                {searchResults.map((result) => (
                  <button
                    key={result.external_id}
                    type="button"
                    onClick={() => handleSelectResult(result)}
                    className="w-full px-4 py-3 text-left hover:bg-gray-50 border-b border-gray-100 last:border-b-0"
                  >
                    <div className="font-medium text-gray-900">{result.name}</div>
                    {result.team && (
                      <div className="text-sm text-gray-500">{result.team}</div>
                    )}
                  </button>
                ))}
              </div>
            )}
          </div>
          <button
            type="submit"
            disabled={loading || !input.trim()}
            className="px-6 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {loading ? 'Adding...' : 'Add'}
          </button>
        </div>
      </form>
      {error && (
        <p className="mt-2 text-sm text-red-600">{error}</p>
      )}
      <p className="mt-2 text-sm text-gray-500">
        Search for a gymnast by name, or paste a MyMeetScores URL
      </p>
    </div>
  );
}
