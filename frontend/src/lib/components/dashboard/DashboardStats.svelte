<script lang="ts">
  import {onMount} from 'svelte';
  import {api} from '$lib/api/client';
  import type {DashboardMetrics, DashboardCardConfig} from '$lib/types/dashboard';
  import StatsCard from '$lib/components/dashboard/StatsCard.svelte';

  let metrics = $state<DashboardMetrics | null>(null);
  let loading = $state(true);

  const fmt = (n: number) => n.toLocaleString('fr-FR');

  const cards: DashboardCardConfig[] = $derived([
    {
      label: 'Camions actifs',
      icon: 'truck',
      value: metrics ? String(metrics.trucks.total) : '',
      sub: metrics
        ? `${metrics.trucks.on_trip} en route · ${metrics.trucks.ready} prêts · ${metrics.trucks.in_maintenance} maintenance`
        : '',
    },
    {
      label: 'Trajets en cours',
      icon: 'navigation',
      value: metrics ? String(metrics.trips_in_progress) : '',
      sub: 'Actuellement actifs',
    },
    {
      label: 'Litres livrés',
      icon: 'download',
      value: metrics ? `${fmt(metrics.liters_delivered_this_month)} L` : '',
      sub: 'Ce mois-ci',
    },
    {
      label: 'Facturation HT',
      icon: 'receipt',
      value: metrics ? `${fmt(metrics.billing_amount_ht_this_month)} GNF` : '',
      sub: 'Ce mois-ci',
    },
  ]);

  onMount(async () => {
    try {
      metrics = await api.get<DashboardMetrics>('/dashboard');
    } finally {
      loading = false;
    }
  });
</script>

<div class="grid grid-cols-2 xl:grid-cols-4 gap-4">
  {#each cards as card (card.label)}
    <StatsCard {...card} {loading} />
  {/each}
</div>
