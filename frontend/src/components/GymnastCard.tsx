import { Link } from 'react-router-dom';
import { Gymnast } from '../types';

interface Props {
  gymnast: Gymnast;
}

export default function GymnastCard({ gymnast }: Props) {
  return (
    <Link
      to={`/gymnast/${gymnast.id}`}
      className="block bg-white rounded-lg shadow hover:shadow-md transition-shadow p-6"
    >
      <div className="flex items-start justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">{gymnast.name}</h3>
          <p className="text-sm text-gray-500">{gymnast.team}</p>
        </div>
        {gymnast.latest_level && (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
            Level {gymnast.latest_level}
          </span>
        )}
      </div>
      <div className="mt-4 text-sm text-gray-600">
        {gymnast.scores_count} meets recorded
      </div>
    </Link>
  );
}
