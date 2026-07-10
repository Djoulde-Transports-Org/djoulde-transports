import type {IconName} from '$lib/components/common/Icon.svelte';

export type TruckCounts = {
  total: number;
  ready: number;
  on_trip: number;
  in_maintenance: number;
};

export type DashboardMetrics = {
  trucks: TruckCounts;
  trips_in_progress: number;
  liters_delivered_this_month: number;
  billing_amount_ht_this_month: number;
};

export type DashboardCardConfig = {label: string; icon: IconName; value: string; sub: string};
