import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { Score } from '../types';

interface Props {
  scores: Score[];
  title?: string;
}

export default function ScoreChart({ scores, title }: Props) {
  const sortedScores = [...scores].sort(
    (a, b) => new Date(a.competition.date).getTime() - new Date(b.competition.date).getTime()
  );

  const data = sortedScores.map((score) => ({
    date: new Date(score.competition.date).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
    }),
    meet: score.competition.name,
    vault: score.vault,
    bars: score.bars,
    beam: score.beam,
    floor: score.floor,
    aa: score.all_around,
  }));

  if (data.length < 2) {
    return (
      <div className="bg-white rounded-lg shadow p-6">
        {title && <h3 className="text-lg font-semibold mb-4">{title}</h3>}
        <p className="text-gray-500 text-center py-8">
          Need at least 2 meets to show progress chart
        </p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow p-6">
      {title && <h3 className="text-lg font-semibold mb-4">{title}</h3>}
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data} margin={{ top: 5, right: 30, left: 0, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
          <XAxis dataKey="date" tick={{ fontSize: 12 }} />
          <YAxis domain={[7, 10]} tick={{ fontSize: 12 }} />
          <Tooltip
            contentStyle={{
              backgroundColor: 'white',
              border: '1px solid #e5e7eb',
              borderRadius: '8px',
            }}
            labelFormatter={(label, payload) => {
              if (payload && payload[0]) {
                return payload[0].payload.meet;
              }
              return label;
            }}
          />
          <Legend />
          <Line
            type="monotone"
            dataKey="vault"
            name="Vault"
            stroke="#ef4444"
            strokeWidth={2}
            dot={{ r: 4 }}
            connectNulls
          />
          <Line
            type="monotone"
            dataKey="bars"
            name="Bars"
            stroke="#f59e0b"
            strokeWidth={2}
            dot={{ r: 4 }}
            connectNulls
          />
          <Line
            type="monotone"
            dataKey="beam"
            name="Beam"
            stroke="#10b981"
            strokeWidth={2}
            dot={{ r: 4 }}
            connectNulls
          />
          <Line
            type="monotone"
            dataKey="floor"
            name="Floor"
            stroke="#8b5cf6"
            strokeWidth={2}
            dot={{ r: 4 }}
            connectNulls
          />
          <Line
            type="monotone"
            dataKey="aa"
            name="All-Around"
            stroke="#0ea5e9"
            strokeWidth={3}
            dot={{ r: 5 }}
            connectNulls
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
