import { PersonalBests } from '../types';

interface Props {
  personalBests: PersonalBests;
}

function formatScore(score: number | string | null) {
  if (score === null || score === undefined) return '-';
  const num = typeof score === 'string' ? parseFloat(score) : score;
  if (isNaN(num)) return '-';
  return num.toFixed(3);
}

export default function PersonalBestsCard({ personalBests }: Props) {
  const levels = Object.keys(personalBests)
    .map(Number)
    .sort((a, b) => b - a);

  if (levels.length === 0) {
    return null;
  }

  return (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <div className="px-6 py-4 border-b border-gray-200">
        <h2 className="text-lg font-semibold">Personal Bests</h2>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Level
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">
                Vault
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">
                Bars
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">
                Beam
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">
                Floor
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">
                AA
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {levels.map((level) => {
              const bests = personalBests[level];
              return (
                <tr key={level}>
                  <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                    Level {level}
                  </td>
                  <td className="px-4 py-3 whitespace-nowrap text-sm text-center font-mono text-primary-600 font-semibold">
                    {formatScore(bests.vault)}
                  </td>
                  <td className="px-4 py-3 whitespace-nowrap text-sm text-center font-mono text-primary-600 font-semibold">
                    {formatScore(bests.bars)}
                  </td>
                  <td className="px-4 py-3 whitespace-nowrap text-sm text-center font-mono text-primary-600 font-semibold">
                    {formatScore(bests.beam)}
                  </td>
                  <td className="px-4 py-3 whitespace-nowrap text-sm text-center font-mono text-primary-600 font-semibold">
                    {formatScore(bests.floor)}
                  </td>
                  <td className="px-4 py-3 whitespace-nowrap text-sm text-center font-mono text-primary-700 font-bold">
                    {formatScore(bests.all_around)}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
