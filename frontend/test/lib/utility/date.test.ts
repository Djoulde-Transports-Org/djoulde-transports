import {formatShortDate, formatDate} from '$lib/utility/date';

describe('formatShortDate', () => {
  it('formats an ISO datetime as DD/MM', () => {
    expect(formatShortDate('2026-06-25T08:00:00Z')).toBe('25/06');
  });

  it('pads single-digit day and month', () => {
    expect(formatShortDate('2026-01-05T08:00:00Z')).toBe('05/01');
  });

  it('returns — when given null', () => {
    expect(formatShortDate(null)).toBe('—');
  });
});

describe('formatDate', () => {
  it('formats an ISO datetime as DD/MM/YYYY', () => {
    expect(formatDate('2026-06-25T08:00:00Z')).toBe('25/06/2026');
  });

  it('pads single-digit day and month', () => {
    expect(formatDate('2026-01-05T08:00:00Z')).toBe('05/01/2026');
  });

  it('returns — when given null', () => {
    expect(formatDate(null)).toBe('—');
  });
});
