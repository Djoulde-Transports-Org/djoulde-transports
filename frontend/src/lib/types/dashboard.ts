import type {IconName} from '$lib/components/common/Icon.svelte';

export type TruckCounts = {
  total: number;
  ready: number;
  onTrip: number;
  inMaintenance: number;
};

export type DashboardMetrics = {
  trucks: TruckCounts;
  tripsInProgress: number;
  litersDeliveredThisMonth: number;
  billingAmountHtThisMonth: number;
};

export type DashboardCardConfig = {label: string; icon: IconName; value: string; sub: string};
