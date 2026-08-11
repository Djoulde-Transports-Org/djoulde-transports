<script lang="ts">
  import Icon from '$lib/components/common/Icon.svelte';
  import Form from '$lib/components/common/Form.svelte';
  import Combobox from '$lib/components/common/Combobox.svelte';
  import {getAllTrucks} from '$lib/api/trucks';
  import {getEmployees} from '$lib/api/employees';
  import {getMaintenanceKinds} from '$lib/api/maintenanceKinds';
  import {createMaintenance} from '$lib/api/maintenances';
  import type {Truck} from '$lib/types/truck';
  import type {Employee} from '$lib/types/employee';
  import type {MaintenanceKindOption} from '$lib/types/maintenanceKind';
  import type {CreateMaintenancePayload, NewMaintenanceValues} from '$lib/types/maintenance';
  import {newMaintenanceSchema} from '$lib/store/newMaintenance';
  import {maintenanceKindLabel} from '$lib/store/maintenanceKind';
  import {compact} from '$lib/utility/object';

  let {open, onClose, onCreated}: {open: boolean; onClose: () => void; onCreated: () => void} =
    $props();

  let trucks = $state<Truck[]>([]);
  let technicians = $state<Employee[]>([]);
  let kinds = $state<MaintenanceKindOption[]>([]);
  let apiError = $state<string | null>(null);

  const technicianOptions = $derived(
    technicians
      .filter((employee) => employee.userId !== null)
      .map((employee) => ({value: employee.userId as number, label: employee.fullName}))
  );

  const kindOptions = $derived(
    kinds.map((kind) => ({value: kind.name, label: maintenanceKindLabel(kind.name)}))
  );

  const loadOptions = async () => {
    const [truckRes, technicianRes, kindRes] = await Promise.all([
      getAllTrucks(),
      getEmployees('mechanic'),
      getMaintenanceKinds(),
    ]);
    trucks = truckRes.data;
    technicians = technicianRes.data;
    kinds = kindRes.data;
  };

  $effect(() => {
    if (open) {
      apiError = null;
      loadOptions();
    }
  });

  $effect(() => {
    const handleKeydown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && open) onClose();
    };
    window.addEventListener('keydown', handleKeydown);
    return () => window.removeEventListener('keydown', handleKeydown);
  });

  const handleSubmit = async (values: NewMaintenanceValues) => {
    apiError = null;
    const payload: CreateMaintenancePayload = {
      truckId: Number(values.truckId),
      performedOn: values.performedOn,
      ...compact({
        kind: values.kind,
        performedById: values.performedById ? Number(values.performedById) : undefined,
        estimatedDuration: values.estimatedDuration ? Number(values.estimatedDuration) : undefined,
      }),
      ...(values.estimatedCost
        ? {parts: [{name: 'Coût estimé', price: Number(values.estimatedCost)}]}
        : {}),
    };

    const {data, error} = await createMaintenance(payload);

    if (error) {
      apiError = error;
      return;
    }

    if (data) {
      onCreated();
      onClose();
    }
  };
</script>

{#snippet field(
  id: string,
  label: string,
  error: string | null | undefined,
  type = 'text',
  optional = false
)}
  <div>
    <label
      for={id}
      class="block text-[11px] text-dt-text-muted uppercase tracking-wider mb-1 {error
        ? 'text-dt-red'
        : ''}"
    >
      {label}{optional ? ' (optionnel)' : ''}
    </label>
    <input
      {id}
      name={id}
      {type}
      class="w-full px-3 py-2 text-[13px] rounded-lg border bg-surface text-dt-text focus:outline-none focus:ring-1 transition-colors
        {error ? 'border-dt-red focus:ring-dt-red/40' : 'border-border focus:ring-accent/40'}"
    />
    {#if error}
      <p class="mt-1 text-[11px] text-dt-red">{error}</p>
    {/if}
  </div>
{/snippet}

{#if open}
  <div
    class="fixed inset-0 bg-ground/70 z-40"
    onclick={onClose}
    role="presentation"
    aria-hidden="true"
  ></div>

  <div
    class="fixed inset-y-0 right-0 z-50 w-[500px] max-w-[90vw] bg-surface border-l border-border flex flex-col"
    role="dialog"
    aria-modal="true"
    aria-label="Ouvrir un chantier"
  >
    <div class="flex items-center justify-between px-5 py-4 border-b border-border">
      <div class="text-[16px] font-bold text-dt-text">Ouvrir un chantier</div>
      <button
        onclick={onClose}
        aria-label="Fermer"
        class="text-dt-text-muted hover:text-dt-text transition-colors duration-[130ms]"
      >
        <Icon name="x" size={18} />
      </button>
    </div>

    <Form
      id="new-maintenance"
      schema={newMaintenanceSchema}
      onSubmit={handleSubmit}
      class="flex-1 flex flex-col min-h-0"
    >
      {#snippet children({errors, isValid, isSubmitting})}
        <div class="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-4">
          <Combobox
            id="truckId"
            name="truckId"
            label="Camion"
            options={trucks.map((t) => ({value: t.id, label: t.plateNumber}))}
            error={errors.truckId}
          />

          <Combobox
            id="kind"
            name="kind"
            label="Type de maintenance"
            options={kindOptions}
            emptyLabel="Sélectionner un type"
            creatable
            error={errors.kind}
          />

          <Combobox
            id="performedById"
            name="performedById"
            label="Technicien (optionnel)"
            options={technicianOptions}
            emptyLabel="Non assigné pour l'instant"
            error={errors.performedById}
          />

          {@render field('performedOn', 'Date de début', errors.performedOn, 'date')}

          <div class="grid grid-cols-2 gap-4">
            {@render field(
              'estimatedDuration',
              'Durée estimée (h)',
              errors.estimatedDuration,
              'number',
              true
            )}
            {@render field(
              'estimatedCost',
              'Coût estimé (GNF)',
              errors.estimatedCost,
              'number',
              true
            )}
          </div>

          {#if apiError}
            <p class="text-[13px] text-dt-red">{apiError}</p>
          {/if}
        </div>

        <div class="px-5 py-4 border-t border-border flex gap-3">
          <button
            type="button"
            onclick={onClose}
            class="flex-1 px-4 py-2 text-[13px] font-medium rounded-lg border border-border text-dt-text hover:bg-surface-2 transition-colors duration-[130ms]"
          >
            Annuler
          </button>
          <button
            type="submit"
            disabled={!isValid || isSubmitting}
            class="flex-1 px-4 py-2 text-[13px] font-medium rounded-lg bg-accent text-white hover:bg-accent/90 transition-colors duration-[130ms] disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSubmitting ? 'Création...' : 'Ouvrir le chantier'}
          </button>
        </div>
      {/snippet}
    </Form>
  </div>
{/if}
