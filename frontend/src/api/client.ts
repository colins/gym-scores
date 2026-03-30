import { Gymnast, GymnastDetail } from '../types';

const API_BASE = '/api/v1';

export async function fetchGymnasts(): Promise<Gymnast[]> {
  const response = await fetch(`${API_BASE}/gymnasts`);
  if (!response.ok) throw new Error('Failed to fetch gymnasts');
  return response.json();
}

export async function fetchGymnast(id: number): Promise<GymnastDetail> {
  const response = await fetch(`${API_BASE}/gymnasts/${id}`);
  if (!response.ok) throw new Error('Failed to fetch gymnast');
  return response.json();
}

export async function scrapeGymnast(urlOrId: string): Promise<{ gymnast: Gymnast }> {
  const body = urlOrId.includes('http')
    ? { url: urlOrId }
    : { external_id: urlOrId };

  const response = await fetch(`${API_BASE}/scrape`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to scrape gymnast');
  }
  return response.json();
}

export async function refreshGymnast(id: number): Promise<{ gymnast: Gymnast }> {
  const response = await fetch(`${API_BASE}/gymnasts/${id}/refresh`, {
    method: 'POST',
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to refresh gymnast');
  }
  return response.json();
}
