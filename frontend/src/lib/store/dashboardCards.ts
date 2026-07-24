import type {DashboardCardConfig, DashboardMetrics} from '$lib/types/dashboard';

const formatNumber = (n: number) => n.toLocaleString('fr-FR');

export const buildDashboardCards = (metrics: DashboardMetrics | null): DashboardCardConfig[] => [
  {
    label: 'Camions actifs',
    icon: 'truck',
    value: metrics ? String(metrics.trucks.total) : '',
    sub: metrics
      ? `${metrics.trucks.onTrip} en route · ${metrics.trucks.ready} prêts · ${metrics.trucks.inMaintenance} maintenance`
      : '',
  },
  {
    label: 'Trajets en cours',
    icon: 'navigation',
    value: metrics ? String(metrics.tripsInProgress) : '',
    sub: 'Actuellement actifs',
  },
  {
    label: 'Litres livrés',
    icon: 'download',
    value: metrics ? `${formatNumber(metrics.litersDeliveredThisMonth)} L` : '',
    sub: 'Ce mois-ci',
  },
  {
    label: 'Facturation HT',
    icon: 'receipt',
    value: metrics ? `${formatNumber(metrics.billingAmountHtThisMonth)} GNF` : '',
    sub: 'Ce mois-ci',
  },
];
