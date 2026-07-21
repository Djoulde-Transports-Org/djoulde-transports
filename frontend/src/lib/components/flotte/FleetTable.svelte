<script lang="ts">
  import DataTable from '$lib/components/common/DataTable.svelte';
  import type {Truck, TruckStatus} from '$lib/types/truck';
  import {formatDate} from '$lib/utility/date';

  const STATUS_BADGE: Record<TruckStatus, {label: string; classes: string}> = {
    on_trip: {label: 'En route', classes: 'bg-accent/10 text-accent border-accent/20'},
    in_maintenance: {
      label: 'Maintenance',
      classes: 'bg-dt-yellow/10 text-dt-yellow border-dt-yellow/20',
    },
    ready: {label: 'Prêt', classes: 'bg-dt-green/10 text-dt-green border-dt-green/20'},
  };

  const formatModel = (truck: Truck) => {
    const makeModel = [truck.make, truck.model].filter(Boolean).join(' ');
    if (!makeModel && !truck.year) return '—';
    return [makeModel, truck.year].filter(Boolean).join(' · ');
  };

  const citerne = (truck: Truck) =>
    truck.tank
      ? `${truck.tank.plate_number} · ${truck.tank.capacity.toLocaleString('fr-FR')} L`
      : '—';
</script>

{#snippet plateCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  <span class="font-bold text-dt-text">{truck.plate_number}</span>
{/snippet}

{#snippet modelCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {formatModel(truck)}
{/snippet}

{#snippet citerneCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {citerne(truck)}
{/snippet}

{#snippet statusCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  <span
    class="text-[10px] font-bold px-2.5 py-0.5 rounded-full border {STATUS_BADGE[truck.status]
      .classes}"
  >
    {STATUS_BADGE[truck.status].label}
  </span>
{/snippet}

{#snippet oilChangeCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {formatDate(truck.last_oil_change_on)}
{/snippet}

<DataTable
  endpoint="/trucks?per_page=100"
  rowClickable
  columns={[
    {key: 'plate_number', label: 'Immatriculation', render: plateCell},
    {key: 'model', label: 'Modèle', render: modelCell},
    {key: 'tank', label: 'Citerne', render: citerneCell},
    {key: 'status', label: 'Statut', render: statusCell},
    {key: 'last_oil_change_on', label: 'Dernière vidange', render: oilChangeCell},
  ]}
/>
