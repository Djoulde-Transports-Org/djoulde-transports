<script lang="ts">
  import DashboardStats from '$lib/components/dashboard/DashboardStats.svelte';
  import FleetLanes from '$lib/components/dashboard/FleetLanes.svelte';
  import RecentTrips from '$lib/components/dashboard/RecentTrips.svelte';
</script>

<div class="p-8 flex flex-col gap-6">
  <DashboardStats />
  <FleetLanes />
  <RecentTrips />
</div>
