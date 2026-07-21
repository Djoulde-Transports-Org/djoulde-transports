import {expiryPill} from '$lib/utility/expiry';

describe('expiryPill', () => {
  it('shows a green pill with days remaining when more than 60 days remain', () => {
    expect(expiryPill(120)).toEqual({
      label: 'dans 120j',
      classes: 'bg-dt-green/10 text-dt-green border-dt-green/20',
    });
  });

  it('shows a yellow pill with days remaining when 15 to 60 days remain', () => {
    expect(expiryPill(45)).toEqual({
      label: 'dans 45j',
      classes: 'bg-dt-yellow/10 text-dt-yellow border-dt-yellow/20',
    });
    expect(expiryPill(60)).toEqual({
      label: 'dans 60j',
      classes: 'bg-dt-yellow/10 text-dt-yellow border-dt-yellow/20',
    });
  });

  it('shows a red pill with days remaining when fewer than 15 days remain', () => {
    expect(expiryPill(8)).toEqual({
      label: 'dans 8j',
      classes: 'bg-dt-red/10 text-dt-red border-dt-red/20',
    });
  });

  it('shows a red Expiré pill when days remaining is zero or negative', () => {
    expect(expiryPill(0)).toEqual({
      label: 'Expiré',
      classes: 'bg-dt-red/10 text-dt-red border-dt-red/20',
    });
    expect(expiryPill(-5)).toEqual({
      label: 'Expiré',
      classes: 'bg-dt-red/10 text-dt-red border-dt-red/20',
    });
  });

  it('shows a neutral N/A pill when given null', () => {
    expect(expiryPill(null)).toEqual({
      label: 'N/A',
      classes: 'bg-surface-2 text-dt-text-muted border-border',
    });
  });
});
