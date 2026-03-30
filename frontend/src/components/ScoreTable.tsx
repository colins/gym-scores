import { Score } from '../types';

interface Props {
  scores: Score[];
  showCompetition?: boolean;
}

function formatScore(score: number | null, rank: number | null) {
  if (score === null) return '-';
  const rankStr = rank ? ` (${rank})` : '';
  return `${score.toFixed(3)}${rankStr}`;
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
}

export default function ScoreTable({ scores, showCompetition = true }: Props) {
  if (scores.length === 0) {
    return <p className="text-gray-500 text-center py-8">No scores recorded</p>;
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {showCompetition && (
              <>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Meet
                </th>
              </>
            )}
            <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
              Level
            </th>
            <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
              Division
            </th>
            <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
              Vault
            </th>
            <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
              Bars
            </th>
            <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
              Beam
            </th>
            <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
              Floor
            </th>
            <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
              AA
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {scores.map((score) => (
            <tr key={score.id} className="hover:bg-gray-50">
              {showCompetition && (
                <>
                  <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-500">
                    {formatDate(score.competition.date)}
                  </td>
                  <td className="px-4 py-4 text-sm text-gray-900">
                    {score.competition.name}
                  </td>
                </>
              )}
              <td className="px-4 py-4 whitespace-nowrap text-sm text-center text-gray-900">
                {score.level}
              </td>
              <td className="px-4 py-4 whitespace-nowrap text-sm text-center text-gray-500">
                {score.division}
              </td>
              <td className="px-4 py-4 whitespace-nowrap text-sm text-center font-mono">
                {formatScore(score.vault, score.vault_rank)}
              </td>
              <td className="px-4 py-4 whitespace-nowrap text-sm text-center font-mono">
                {formatScore(score.bars, score.bars_rank)}
              </td>
              <td className="px-4 py-4 whitespace-nowrap text-sm text-center font-mono">
                {formatScore(score.beam, score.beam_rank)}
              </td>
              <td className="px-4 py-4 whitespace-nowrap text-sm text-center font-mono">
                {formatScore(score.floor, score.floor_rank)}
              </td>
              <td className="px-4 py-4 whitespace-nowrap text-sm text-center font-mono font-semibold">
                {formatScore(score.all_around, score.all_around_rank)}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
