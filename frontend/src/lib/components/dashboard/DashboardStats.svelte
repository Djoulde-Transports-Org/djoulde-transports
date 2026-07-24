<script lang="ts">
  import {onMount} from 'svelte';
  import {api} from '$lib/api/client';
  import type {DashboardMetrics} from '$lib/types/dashboard';
  import {buildDashboardCards} from '$lib/store/dashboardCards';
  import StatsCard from '$lib/components/dashboard/StatsCard.svelte';

  let metrics = $state<DashboardMetrics | null>(null);
  let loading = $state(true);

  const cards = $derived(buildDashboardCards(metrics));

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
