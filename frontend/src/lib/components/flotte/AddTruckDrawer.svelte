<script lang="ts">
  import * as yup from 'yup';
  import Icon from '$lib/components/common/Icon.svelte';
  import Form from '$lib/components/common/Form.svelte';
  import Select from '$lib/components/common/Select.svelte';
  import Combobox from '$lib/components/common/Combobox.svelte';
  import {getEmployees} from '$lib/api/employees';
  import {createTruck} from '$lib/api/trucks';
  import type {Employee} from '$lib/types/employee';

  let {open, onClose, onCreated}: {open: boolean; onClose: () => void; onCreated: () => void} =
    $props();

  type AddTruckValues = {
    plate_number: string;
    vin: string;
    make: string;
    model: string;
    year: string;
    status: string;
    tank_plate_number: string;
    tank_capacity: string;
    tank_make: string;
    tank_model: string;
    tank_vin: string;
    tank_year: string;
    driver_id: string;
    last_oil_change_on: string;
    truck_insurance_expires_on: string;
    cargo_insurance_expires_on: string;
    technical_inspection_expires_on: string;
    operating_permit_expires_on: string;
    truck_registration_expires_on: string;
  };

  const STATUS_OPTIONS = [
    {value: 'ready', label: 'Prêt'},
    {value: 'in_maintenance', label: 'Maintenance'},
    {value: 'on_trip', label: 'En route'},
  ];

  const currentYear = new Date().getFullYear();

  const schema = yup.object({
    plate_number: yup.string().required("L'immatriculation est requise"),
    vin: yup.string().optional(),
    make: yup.string().optional(),
    model: yup.string().required('Le modèle est requis'),
    year: yup
      .string()
      .required("L'année est requise")
      .matches(/^\d{4}$/, {message: 'Année invalide', excludeEmptyString: true})
      .test('year-range', 'Année invalide', (value) => {
        if (!value) return true;
        const year = Number(value);
        return year > 1900 && year <= currentYear + 1;
      }),
    status: yup.string().optional(),
    tank_plate_number: yup.string().required("L'immatriculation de la citerne est requise"),
    tank_capacity: yup
      .string()
      .required('La capacité est requise')
      .matches(/^\d+$/, {message: 'Capacité invalide', excludeEmptyString: true}),
    tank_make: yup.string().optional(),
    tank_model: yup.string().optional(),
    tank_vin: yup.string().optional(),
    tank_year: yup.string().optional(),
    driver_id: yup.string().optional(),
    last_oil_change_on: yup.string().optional(),
    truck_insurance_expires_on: yup.string().optional(),
    cargo_insurance_expires_on: yup.string().optional(),
    technical_inspection_expires_on: yup.string().optional(),
    operating_permit_expires_on: yup.string().optional(),
    truck_registration_expires_on: yup.string().optional(),
  });

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
      plate_number: values.plate_number,
      model: values.model,
      year: Number(values.year),
      ...(values.vin ? {vin: values.vin} : {}),
      ...(values.make ? {make: values.make} : {}),
      ...(values.status ? {status: values.status} : {}),
      tank: {
        plate_number: values.tank_plate_number,
        capacity: Number(values.tank_capacity),
        ...(values.tank_vin ? {vin: values.tank_vin} : {}),
        ...(values.tank_make ? {make: values.tank_make} : {}),
        ...(values.tank_model ? {model: values.tank_model} : {}),
        ...(values.tank_year ? {year: Number(values.tank_year)} : {}),
      },
      ...(values.driver_id ? {driver_id: Number(values.driver_id)} : {}),
      ...(values.last_oil_change_on ? {last_oil_change_on: values.last_oil_change_on} : {}),
      documents: {
        ...(values.truck_insurance_expires_on
          ? {truck_insurance_expires_on: values.truck_insurance_expires_on}
          : {}),
        ...(values.cargo_insurance_expires_on
          ? {cargo_insurance_expires_on: values.cargo_insurance_expires_on}
          : {}),
        ...(values.technical_inspection_expires_on
          ? {technical_inspection_expires_on: values.technical_inspection_expires_on}
          : {}),
        ...(values.operating_permit_expires_on
          ? {operating_permit_expires_on: values.operating_permit_expires_on}
          : {}),
        ...(values.truck_registration_expires_on
          ? {truck_registration_expires_on: values.truck_registration_expires_on}
          : {}),
      },
    });

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

    <Form id="add-truck" {schema} onSubmit={handleSubmit} class="flex-1 flex flex-col min-h-0">
      {#snippet children({errors, isValid, isSubmitting})}
        <div class="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-6">
          <div>
            {@render sectionHeader('01', 'Tracteur')}
            <div class="flex flex-col gap-4">
              <div class="grid grid-cols-2 gap-4">
                {@render field('plate_number', 'Immatriculation', errors.plate_number)}
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
                options={STATUS_OPTIONS}
                value="ready"
                error={errors.status}
              />
            </div>
          </div>

          <div>
            {@render sectionHeader('02', 'Citerne')}
            <div class="flex flex-col gap-4">
              <div class="grid grid-cols-2 gap-4">
                {@render field('tank_plate_number', 'Immatriculation', errors.tank_plate_number)}
                {@render field('tank_capacity', 'Capacité (L)', errors.tank_capacity, 'number')}
              </div>
              <div class="grid grid-cols-2 gap-4">
                {@render field('tank_make', 'Marque', errors.tank_make)}
                {@render field('tank_model', 'Modèle', errors.tank_model)}
              </div>
              <div class="grid grid-cols-2 gap-4">
                {@render field('tank_vin', 'VIN', errors.tank_vin)}
                {@render field('tank_year', 'Année', errors.tank_year, 'number')}
              </div>
            </div>
          </div>

          <div>
            {@render sectionHeader('03', 'Chauffeur', true)}
            <Combobox
              id="driver_id"
              name="driver_id"
              label="Affectation"
              options={drivers.map((driver) => ({value: driver.id, label: driver.full_name}))}
              emptyLabel="Non affecté pour l'instant"
              error={errors.driver_id}
            />
          </div>

          <div>
            {@render sectionHeader('04', 'Documents')}
            <div class="grid grid-cols-2 gap-4">
              {@render field(
                'last_oil_change_on',
                'Dernière vidange',
                errors.last_oil_change_on,
                'date'
              )}
              {@render field(
                'truck_insurance_expires_on',
                'Ass. camion',
                errors.truck_insurance_expires_on,
                'date'
              )}
              {@render field(
                'cargo_insurance_expires_on',
                'Ass. produit',
                errors.cargo_insurance_expires_on,
                'date'
              )}
              {@render field(
                'technical_inspection_expires_on',
                'Visite tech.',
                errors.technical_inspection_expires_on,
                'date'
              )}
              {@render field(
                'operating_permit_expires_on',
                'Carte de Transport',
                errors.operating_permit_expires_on,
                'date'
              )}
              {@render field(
                'truck_registration_expires_on',
                'Carte grise',
                errors.truck_registration_expires_on,
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
