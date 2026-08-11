<script lang="ts">
  import type {Snippet} from 'svelte';
  import DataTable from '$lib/components/common/DataTable.svelte';
  import NewMaintenanceDrawer from '$lib/components/maintenance/NewMaintenanceDrawer.svelte';
  import type {Maintenance} from '$lib/types/maintenance';
  import type {Row} from '$lib/types/dataTable';
  import {formatDate} from '$lib/utility/date';
  import {maintenanceStateMeta, maintenanceStateFilters} from '$lib/store/maintenanceState';
  import {maintenanceKindLabel} from '$lib/store/maintenanceKind';
  import {maintenanceColumns} from '$lib/store/maintenanceColumns';
  import type {MaintenanceColumnCell} from '$lib/types/maintenanceColumns';

  let table: ReturnType<typeof DataTable> | undefined = $state();
  let drawerOpen = $state(false);

  const handleCreated = () => table?.refresh();

  const cellRenderers: Record<MaintenanceColumnCell, Snippet<[unknown, Row]>> = {
    truck: truckCell,
    kind: kindCell,
    description: descriptionCell,
    technician: technicianCell,
    date: dateCell,
    duration: durationCell,
    cost: costCell,
    status: statusCell,
  };

  const columns = maintenanceColumns.map((c) => ({
    key: c.key,
    label: c.label,
    render: cellRenderers[c.cell],
  }));
</script>

{#snippet truckCell(_value: unknown, row: Row)}
  {@const maintenance = row as Maintenance}
  <span class="font-bold text-dt-text">{maintenance.truck.plateNumber}</span>
{/snippet}

{#snippet kindCell(_value: unknown, row: Row)}
  {@const maintenance = row as Maintenance}
  <span
    class="text-[11px] font-medium px-2 py-0.5 rounded-full border bg-surface-2 text-dt-text-mid border-border"
  >
    {maintenanceKindLabel(maintenance.kind)}
  </span>
{/snippet}

{#snippet descriptionCell(_value: unknown, row: Row)}
  {@const maintenance = row as Maintenance}
  {maintenance.description ?? '—'}
{/snippet}

{#snippet technicianCell(_value: unknown, row: Row)}
  {@const maintenance = row as Maintenance}
  {maintenance.technician?.name ?? '—'}
{/snippet}

{#snippet dateCell(_value: unknown, row: Row)}
  {@const maintenance = row as Maintenance}
  {formatDate(maintenance.performedOn)}
{/snippet}

{#snippet durationCell(_value: unknown, row: Row)}
  {@const maintenance = row as Maintenance}
  {maintenance.duration ?? '—'}
{/snippet}

{#snippet costCell(_value: unknown, row: Row)}
  {@const maintenance = row as Maintenance}
  {maintenance.cost !== null ? `${maintenance.cost.toLocaleString('fr-FR')} GNF` : '—'}
{/snippet}

{#snippet statusCell(_value: unknown, row: Row)}
  {@const maintenance = row as Maintenance}
  <span
    class="inline-flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-0.5 rounded-full border {maintenanceStateMeta[
      maintenance.state
    ].classes}"
  >
    <span class="w-1.5 h-1.5 rounded-full bg-current"></span>
    {maintenanceStateMeta[maintenance.state].label}
  </span>
{/snippet}

{#snippet openMaintenanceAction()}
  <button
    onclick={() => (drawerOpen = true)}
    class="px-3 py-1.5 text-[13px] font-medium rounded-lg bg-accent text-white hover:bg-accent/90 transition-colors duration-[130ms]"
  >
    + Ouvrir un chantier
  </button>
{/snippet}

<DataTable
  bind:this={table}
  endpoint="/maintenances"
  paginated
  actions={openMaintenanceAction}
  filters={maintenanceStateFilters}
  searchParam="search"
  {columns}
/>

<NewMaintenanceDrawer
  open={drawerOpen}
  onClose={() => (drawerOpen = false)}
  onCreated={handleCreated}
/>
