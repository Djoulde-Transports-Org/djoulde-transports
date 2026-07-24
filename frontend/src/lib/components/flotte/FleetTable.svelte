<script lang="ts">
  import type {Snippet} from 'svelte';
  import DataTable from '$lib/components/common/DataTable.svelte';
  import AddTruckDrawer from '$lib/components/flotte/AddTruckDrawer.svelte';
  import TruckDrawer from '$lib/components/flotte/TruckDrawer.svelte';
  import type {Truck} from '$lib/types/truck';
  import type {Row} from '$lib/types/dataTable';
  import {formatDate} from '$lib/utility/date';
  import {expiryPill} from '$lib/utility/expiry';
  import {formatTruckModel, formatTankSummary} from '$lib/utility/truck';
  import {truckStatusMeta, truckStatusFilters} from '$lib/store/truckStatus';
  import {fleetColumns} from '$lib/store/fleetColumns';
  import type {FleetColumnCell} from '$lib/types/fleetColumns';

  let table: ReturnType<typeof DataTable> | undefined = $state();
  let drawerOpen = $state(false);
  let selectedTruck = $state<Truck | null>(null);

  const handleCreated = () => table?.refresh();

  const cellRenderers: Record<FleetColumnCell, Snippet<[unknown, Row]>> = {
    plate: plateCell,
    model: modelCell,
    citerne: citerneCell,
    status: statusCell,
    oilChange: oilChangeCell,
    truckInsurance: truckInsuranceCell,
    cargoInsurance: cargoInsuranceCell,
    technicalInspection: technicalInspectionCell,
    operatingPermit: operatingPermitCell,
    truckRegistration: truckRegistrationCell,
    conformityCertificate: conformityCertificateCell,
  };

  const columns = fleetColumns.map((c) => ({
    key: c.key,
    label: c.label,
    render: cellRenderers[c.cell],
  }));
</script>

{#snippet plateCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  <span class="font-bold text-dt-text">{truck.plateNumber}</span>
{/snippet}

{#snippet modelCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {formatTruckModel(truck)}
{/snippet}

{#snippet citerneCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {formatTankSummary(truck.tank)}
{/snippet}

{#snippet statusCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  <span
    class="text-[10px] font-bold px-2.5 py-0.5 rounded-full border {truckStatusMeta[truck.status]
      .classes}"
  >
    {truckStatusMeta[truck.status].label}
  </span>
{/snippet}

{#snippet oilChangeCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {formatDate(truck.lastOilChangeOn)}
{/snippet}

{#snippet truckInsuranceCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.truckInsuranceDaysRemaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet cargoInsuranceCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.cargoInsuranceDaysRemaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet technicalInspectionCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.technicalInspectionDaysRemaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet operatingPermitCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.operatingPermitDaysRemaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet truckRegistrationCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.truckRegistrationDaysRemaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet conformityCertificateCell(_value: unknown, row: Row)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.tank?.conformityCertificateDaysRemaining ?? null)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet addTruckAction()}
  <button
    onclick={() => (drawerOpen = true)}
    class="px-3 py-1.5 text-[13px] font-medium rounded-lg bg-accent text-white hover:bg-accent/90 transition-colors duration-[130ms]"
  >
    Ajouter un camion
  </button>
{/snippet}

<DataTable
  bind:this={table}
  endpoint="/trucks?per_page=100"
  rowClickable
  actions={addTruckAction}
  onRowClick={(row) => (selectedTruck = row as Truck)}
  clientSide
  filters={truckStatusFilters}
  searchParam="search"
  searchFields={['plateNumber', 'model']}
  {columns}
/>

<AddTruckDrawer open={drawerOpen} onClose={() => (drawerOpen = false)} onCreated={handleCreated} />
<TruckDrawer truck={selectedTruck} onClose={() => (selectedTruck = null)} />
