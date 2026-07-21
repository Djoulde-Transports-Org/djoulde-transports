<script lang="ts">
  import DataTable from '$lib/components/common/DataTable.svelte';
  import type {Truck, TruckStatus} from '$lib/types/truck';
  import {formatDate} from '$lib/utility/date';
  import {expiryPill} from '$lib/utility/expiry';

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

{#snippet truckInsuranceCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.truck_insurance_days_remaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet cargoInsuranceCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.cargo_insurance_days_remaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet technicalInspectionCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.technical_inspection_days_remaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet operatingPermitCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.operating_permit_days_remaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet truckRegistrationCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.truck_registration_days_remaining)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
{/snippet}

{#snippet conformityCertificateCell(_value: unknown, row: Record<string, unknown>)}
  {@const truck = row as Truck}
  {@const pill = expiryPill(truck.tank?.conformity_certificate_days_remaining ?? null)}
  <span class="exp text-[11px] font-semibold px-2 py-0.5 rounded-full border {pill.classes}">
    {pill.label}
  </span>
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
    {key: 'truck_insurance_days_remaining', label: 'Ass. camion', render: truckInsuranceCell},
    {key: 'cargo_insurance_days_remaining', label: 'Ass. produit', render: cargoInsuranceCell},
    {
      key: 'technical_inspection_days_remaining',
      label: 'Visite tech.',
      render: technicalInspectionCell,
    },
    {
      key: 'operating_permit_days_remaining',
      label: 'Carte de Transport',
      render: operatingPermitCell,
    },
    {
      key: 'truck_registration_days_remaining',
      label: 'Carte grise',
      render: truckRegistrationCell,
    },
    {key: 'conformity_certificate', label: 'Baremage', render: conformityCertificateCell},
  ]}
/>
