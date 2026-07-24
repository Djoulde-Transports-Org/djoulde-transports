<script lang="ts">
  import Icon from '$lib/components/common/Icon.svelte';
  import Form from '$lib/components/common/Form.svelte';
  import Select from '$lib/components/common/Select.svelte';
  import Combobox from '$lib/components/common/Combobox.svelte';
  import {getEmployees} from '$lib/api/employees';
  import {createTruck} from '$lib/api/trucks';
  import type {Employee} from '$lib/types/employee';
  import type {AddTruckValues, CreateTruckPayload} from '$lib/types/truck';
  import {truckStatusOptions} from '$lib/store/truckStatus';
  import {addTruckSchema} from '$lib/store/addTruck';
  import {compact} from '$lib/utility/object';

  let {open, onClose, onCreated}: {open: boolean; onClose: () => void; onCreated: () => void} =
    $props();

  let drivers = $state<Employee[]>([]);
  let apiError = $state<string | null>(null);

  const loadDrivers = async () => {
    const {data} = await getEmployees('driver');
    drivers = data;
  };

  $effect(() => {
    if (open) {
      apiError = null;
      loadDrivers();
    }
  });

  $effect(() => {
    const handleKeydown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && open) onClose();
    };
    window.addEventListener('keydown', handleKeydown);
    return () => window.removeEventListener('keydown', handleKeydown);
  });

  const handleSubmit = async (values: AddTruckValues) => {
    apiError = null;
    const {data, error} = await createTruck({
      ...compact({
        plateNumber: values.plateNumber,
        model: values.model,
        year: Number(values.year),
        vin: values.vin,
        make: values.make,
        status: values.status,
        driverId: values.driverId ? Number(values.driverId) : undefined,
        lastOilChangeOn: values.lastOilChangeOn,
      }),
      tank: compact({
        plateNumber: values.tankPlateNumber,
        capacity: Number(values.tankCapacity),
        vin: values.tankVin,
        make: values.tankMake,
        model: values.tankModel,
        year: values.tankYear ? Number(values.tankYear) : undefined,
      }),
      documents: compact({
        truckInsuranceExpiresOn: values.truckInsuranceExpiresOn,
        cargoInsuranceExpiresOn: values.cargoInsuranceExpiresOn,
        technicalInspectionExpiresOn: values.technicalInspectionExpiresOn,
        operatingPermitExpiresOn: values.operatingPermitExpiresOn,
        truckRegistrationExpiresOn: values.truckRegistrationExpiresOn,
      }),
    } as CreateTruckPayload);

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

{#snippet sectionHeader(num: string, title: string, optional = false)}
  <div class="flex items-center gap-2 mb-3">
    <span
      class="text-[11px] font-bold text-accent bg-accent/10 border border-accent/20 rounded px-1.5 py-0.5"
    >
      {num}
    </span>
    <span class="text-[13px] font-bold text-dt-text uppercase tracking-wide">{title}</span>
    {#if optional}
      <span class="text-[12px] text-dt-text-muted">(optionnel)</span>
    {/if}
  </div>
{/snippet}

{#snippet field(id: string, label: string, error: string | null | undefined, type = 'text')}
  <div>
    <label
      for={id}
      class="block text-[11px] text-dt-text-muted uppercase tracking-wider mb-1 {error
        ? 'text-dt-red'
        : ''}"
    >
      {label}
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
    class="fixed inset-y-0 right-0 z-50 w-[550px] max-w-[90vw] bg-surface border-l border-border flex flex-col"
    role="dialog"
    aria-modal="true"
    aria-label="Ajouter un camion"
  >
    <div class="flex items-center justify-between px-5 py-4 border-b border-border">
      <div class="text-[16px] font-bold text-dt-text">Ajouter un camion</div>
      <button
        onclick={onClose}
        aria-label="Fermer"
        class="text-dt-text-muted hover:text-dt-text transition-colors duration-[130ms]"
      >
        <Icon name="x" size={18} />
      </button>
    </div>

    <Form
      id="add-truck"
      schema={addTruckSchema}
      onSubmit={handleSubmit}
      class="flex-1 flex flex-col min-h-0"
    >
      {#snippet children({errors, isValid, isSubmitting})}
        <div class="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-6">
          <div>
            {@render sectionHeader('01', 'Tracteur')}
            <div class="flex flex-col gap-4">
              <div class="grid grid-cols-2 gap-4">
                {@render field('plateNumber', 'Immatriculation', errors.plateNumber)}
                {@render field('vin', 'VIN', errors.vin)}
              </div>
              <div class="grid grid-cols-3 gap-4">
                {@render field('make', 'Marque', errors.make)}
                {@render field('model', 'Modèle', errors.model)}
                {@render field('year', 'Année', errors.year, 'number')}
              </div>
              <Select
                id="status"
                name="status"
                label="Statut (optionnel)"
                options={truckStatusOptions}
                value="ready"
                error={errors.status}
              />
            </div>
          </div>

          <div>
            {@render sectionHeader('02', 'Citerne')}
            <div class="flex flex-col gap-4">
              <div class="grid grid-cols-2 gap-4">
                {@render field('tankPlateNumber', 'Immatriculation', errors.tankPlateNumber)}
                {@render field('tankCapacity', 'Capacité (L)', errors.tankCapacity, 'number')}
              </div>
              <div class="grid grid-cols-2 gap-4">
                {@render field('tankMake', 'Marque', errors.tankMake)}
                {@render field('tankModel', 'Modèle', errors.tankModel)}
              </div>
              <div class="grid grid-cols-2 gap-4">
                {@render field('tankVin', 'VIN', errors.tankVin)}
                {@render field('tankYear', 'Année', errors.tankYear, 'number')}
              </div>
            </div>
          </div>

          <div>
            {@render sectionHeader('03', 'Chauffeur', true)}
            <Combobox
              id="driverId"
              name="driverId"
              label="Affectation"
              options={drivers.map((driver) => ({value: driver.id, label: driver.fullName}))}
              emptyLabel="Non affecté pour l'instant"
              error={errors.driverId}
            />
          </div>

          <div>
            {@render sectionHeader('04', 'Documents')}
            <div class="grid grid-cols-2 gap-4">
              {@render field('lastOilChangeOn', 'Dernière vidange', errors.lastOilChangeOn, 'date')}
              {@render field(
                'truckInsuranceExpiresOn',
                'Ass. camion',
                errors.truckInsuranceExpiresOn,
                'date'
              )}
              {@render field(
                'cargoInsuranceExpiresOn',
                'Ass. produit',
                errors.cargoInsuranceExpiresOn,
                'date'
              )}
              {@render field(
                'technicalInspectionExpiresOn',
                'Visite tech.',
                errors.technicalInspectionExpiresOn,
                'date'
              )}
              {@render field(
                'operatingPermitExpiresOn',
                'Carte de Transport',
                errors.operatingPermitExpiresOn,
                'date'
              )}
              {@render field(
                'truckRegistrationExpiresOn',
                'Carte grise',
                errors.truckRegistrationExpiresOn,
                'date'
              )}
            </div>
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
            {isSubmitting ? 'Création...' : 'Créer le camion'}
          </button>
        </div>
      {/snippet}
    </Form>
  </div>
{/if}
