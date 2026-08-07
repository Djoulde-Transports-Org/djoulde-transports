<script lang="ts">
  import type {Snippet} from 'svelte';
  import DataTable from '$lib/components/common/DataTable.svelte';
  import NewTripDrawer from '$lib/components/trajets/NewTripDrawer.svelte';
  import type {Trip} from '$lib/types/trip';
  import type {Row} from '$lib/types/dataTable';
  import {formatDate} from '$lib/utility/date';
  import {formatTankSummary} from '$lib/utility/truck';
  import {tripStatusMeta, tripStatusFilters} from '$lib/store/tripStatus';
  import {tripColumns} from '$lib/store/tripColumns';
  import type {TripColumnCell} from '$lib/types/tripColumns';

  let table: ReturnType<typeof DataTable> | undefined = $state();
  let drawerOpen = $state(false);

  const handleCreated = () => table?.refresh();

  const tripNumber = (id: number) => `#TRJ-${String(id).padStart(4, '0')}`;

  const cellRenderers: Record<TripColumnCell, Snippet<[unknown, Row]>> = {
    number: numberCell,
    truckTank: truckTankCell,
    route: routeCell,
    driver: driverCell,
    gasoil: gasoilCell,
    essence: essenceCell,
    pretaxAmount: pretaxAmountCell,
    status: statusCell,
    departure: departureCell,
  };

  const columns = tripColumns.map((c) => ({
    key: c.key,
    label: c.label,
    render: cellRenderers[c.cell],
  }));
</script>

{#snippet numberCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  <span class="font-mono text-dt-text-muted">{tripNumber(trip.id)}</span>
{/snippet}

{#snippet truckTankCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  <div class="font-bold text-dt-text">{trip.truck.plateNumber}</div>
  <div class="text-[11px] text-dt-text-muted">{formatTankSummary(trip.truck.tank)}</div>
{/snippet}

{#snippet routeCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  {trip.route.origin} → {trip.route.destination}
{/snippet}

{#snippet driverCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  {trip.driver?.fullName ?? '—'}
{/snippet}

{#snippet gasoilCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  {trip.deliveryNote ? trip.deliveryNote.dieselQuantity.toLocaleString('fr-FR') : '—'}
{/snippet}

{#snippet essenceCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  {trip.deliveryNote ? trip.deliveryNote.gasolineQuantity.toLocaleString('fr-FR') : '—'}
{/snippet}

{#snippet pretaxAmountCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  {trip.pretaxAmount !== null ? trip.pretaxAmount.toLocaleString('fr-FR') : '—'}
{/snippet}

{#snippet statusCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  <span
    class="text-[10px] font-bold px-2.5 py-0.5 rounded-full border {tripStatusMeta[trip.status]
      .classes}"
  >
    {tripStatusMeta[trip.status].label}
  </span>
{/snippet}

{#snippet departureCell(_value: unknown, row: Row)}
  {@const trip = row as Trip}
  {formatDate(trip.scheduledStartAt)}
{/snippet}

{#snippet newTripAction()}
  <button
    onclick={() => (drawerOpen = true)}
    class="px-3 py-1.5 text-[13px] font-medium rounded-lg bg-accent text-white hover:bg-accent/90 transition-colors duration-[130ms]"
  >
    Nouveau trajet
  </button>
{/snippet}

<DataTable
  bind:this={table}
  endpoint="/trips"
  paginated
  actions={newTripAction}
  filters={tripStatusFilters}
  {columns}
/>

<NewTripDrawer open={drawerOpen} onClose={() => (drawerOpen = false)} onCreated={handleCreated} />
