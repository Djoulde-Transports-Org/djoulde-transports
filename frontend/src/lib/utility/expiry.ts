export type ExpiryPill = {label: string; classes: string};

export const expiryPill = (daysRemaining: number | null): ExpiryPill => {
  if (daysRemaining === null) {
    return {label: 'N/A', classes: 'bg-surface-2 text-dt-text-muted border-border'};
  }
  if (daysRemaining < 15) {
    return {
      label: daysRemaining <= 0 ? 'Expiré' : `dans ${daysRemaining}j`,
      classes: 'bg-dt-red/10 text-dt-red border-dt-red/20',
    };
  }
  if (daysRemaining <= 60) {
    return {
      label: `dans ${daysRemaining}j`,
      classes: 'bg-dt-yellow/10 text-dt-yellow border-dt-yellow/20',
    };
  }
  return {
    label: `dans ${daysRemaining}j`,
    classes: 'bg-dt-green/10 text-dt-green border-dt-green/20',
  };
};
