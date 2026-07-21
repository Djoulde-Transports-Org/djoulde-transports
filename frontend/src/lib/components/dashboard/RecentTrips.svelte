<script lang="ts">
  import {onMount} from 'svelte';
  import {resolve} from '$app/paths';
  import {getTrips} from '$lib/api/trips';
  import type {Trip, TripStatus} from '$lib/types/trip';
  import {formatShortDate} from '$lib/utility/date';

  let trips = $state<Trip[]>([]);
  let loading = $state(true);
  let errorMsg = $state<string | null>(null);

  const STATUS_BADGE: Record<TripStatus, {label: string; classes: string}> = {
    scheduled: {label: 'Planifié', classes: 'bg-surface-2 text-dt-text-muted border-border'},
    in_progress: {label: 'En cours', classes: 'bg-accent/10 text-accent border-accent/20'},
    completed: {label: 'Terminé', classes: 'bg-dt-green/10 text-dt-green border-dt-green/20'},
    cancelled: {label: 'Annulé', classes: 'bg-dt-red/10 text-dt-red border-dt-red/20'},
  };

  const tripNumber = (id: number) => `#TRJ-${String(id).padStart(4, '0')}`;

  const quantity = (trip: Trip) =>
    trip.delivery_note ? `${trip.delivery_note.total_quantity.toLocaleString('fr-FR')} L` : '—';

  const driverName = (trip: Trip) => trip.driver?.full_name ?? '—';

  onMount(async () => {
    ({data: trips, error: errorMsg} = await getTrips());
    loading = false;
  });
</script>

<div class="bg-surface border border-border rounded-xl overflow-hidden">
  <div class="flex items-center justify-between px-5 py-4 border-b border-border">
    <span class="text-[13px] font-semibold text-dt-text">Derniers trajets</span>
    <a href={resolve('/trajets')} class="text-[12px] text-accent hover:underline">Voir tout →</a>
  </div>

  <div class="overflow-x-auto">
    <table class="w-full text-sm min-w-full">
      <thead>
        <tr class="bg-surface border-b border-border">
          {#each ['N° trajet', 'Camion', 'Route', 'Chauffeur', 'Quantité', 'Statut', 'Date'] as label (label)}
            <th
              class="px-4 py-3 text-left text-[11px] font-semibold text-dt-text-muted uppercase tracking-wider whitespace-nowrap"
            >
              {label}
            </th>
          {/each}
        </tr>
      </thead>
      <tbody>
        {#if loading}
          {#each [0, 1, 2, 3, 4] as i (i)}
            <tr class="border-b border-border-soft last:border-0">
              {#each [0, 1, 2, 3, 4, 5, 6] as j (j)}
                <td class="px-4 py-3">
                  <div
                    class="h-3.5 bg-surface-2 rounded animate-pulse {j % 2 === 0
                      ? 'w-3/4'
                      : 'w-1/2'}"
                  ></div>
                </td>
              {/each}
            </tr>
          {/each}
        {:else if errorMsg}
          <tr>
            <td colspan="7" class="px-4 py-10 text-center text-[13px] text-dt-red">
              {errorMsg}
            </td>
          </tr>
        {:else if trips.length === 0}
          <tr>
            <td colspan="7" class="px-4 py-10 text-center text-[13px] text-dt-text-muted">
              Aucun trajet.
            </td>
          </tr>
        {:else}
          {#each trips as trip (trip.id)}
            <tr
              class="border-b border-border-soft last:border-0 hover:bg-surface-2/40 transition-colors duration-[130ms]"
            >
              <td class="px-4 py-3 font-mono text-dt-text-muted whitespace-nowrap">
                {tripNumber(trip.id)}
              </td>
              <td class="px-4 py-3 font-bold text-dt-text whitespace-nowrap">
                {trip.truck.plate_number}
              </td>
              <td class="px-4 py-3 text-dt-text whitespace-nowrap">
                {trip.route.origin} → {trip.route.destination}
              </td>
              <td class="px-4 py-3 text-dt-text-muted whitespace-nowrap">
                {driverName(trip)}
              </td>
              <td class="px-4 py-3 text-dt-text whitespace-nowrap">
                {quantity(trip)}
              </td>
              <td class="px-4 py-3 whitespace-nowrap">
                <span
                  class="text-[10px] font-bold px-2.5 py-0.5 rounded-full border {STATUS_BADGE[
                    trip.status
                  ].classes}"
                >
                  {STATUS_BADGE[trip.status].label}
                </span>
              </td>
              <td class="px-4 py-3 text-dt-text-muted whitespace-nowrap">
                {formatShortDate(trip.scheduled_start_at)}
              </td>
            </tr>
          {/each}
        {/if}
      </tbody>
    </table>
  </div>
</div>
