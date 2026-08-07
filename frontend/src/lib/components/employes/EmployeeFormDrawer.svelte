<script lang="ts">
  import Icon from '$lib/components/common/Icon.svelte';
  import Form from '$lib/components/common/Form.svelte';
  import Select from '$lib/components/common/Select.svelte';
  import {createEmployee, updateEmployee} from '$lib/api/employees';
  import {getAllTrucks} from '$lib/api/trucks';
  import type {Employee, EmployeeFormValues, EmployeePayload} from '$lib/types/employee';
  import type {Truck} from '$lib/types/truck';
  import {employeeRoleOptions} from '$lib/store/employeeRole';
  import {employeeStatusOptions} from '$lib/store/employeeStatus';
  import {employeeFormSchema} from '$lib/store/employeeForm';
  import {compact} from '$lib/utility/object';

  let {
    open,
    employee = null,
    onClose,
    onSaved,
  }: {
    open: boolean;
    employee?: Employee | null;
    onClose: () => void;
    onSaved: () => void;
  } = $props();

  let trucks = $state<Truck[]>([]);
  let apiError = $state<string | null>(null);
  let role = $state('driver');

  const isEdit = $derived(employee !== null);

  const loadTrucks = async () => {
    const {data} = await getAllTrucks();
    trucks = data;
  };

  $effect(() => {
    if (open) {
      apiError = null;
      role = employee?.role ?? 'driver';
      loadTrucks();
    }
  });

  $effect(() => {
    const handleKeydown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && open) onClose();
    };
    window.addEventListener('keydown', handleKeydown);
    return () => window.removeEventListener('keydown', handleKeydown);
  });

  const handleSubmit = async (values: EmployeeFormValues) => {
    apiError = null;
    const payload: EmployeePayload = {
      ...compact({
        firstName: values.firstName,
        lastName: values.lastName,
        role: values.role,
        phoneNumber: values.phoneNumber,
        address: values.address,
        hireDate: values.hireDate,
        status: values.status,
      }),
      truckId: values.role === 'driver' && values.truckId ? Number(values.truckId) : null,
    };

    const {data, error} = employee
      ? await updateEmployee(employee.id, payload)
      : await createEmployee(payload);

    if (error) {
      apiError = error;
      return;
    }

    if (data) {
      onSaved();
      onClose();
    }
  };
</script>

{#snippet field(
  id: string,
  label: string,
  error: string | null | undefined,
  defaultValue = '',
  type = 'text'
)}
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
      value={defaultValue}
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
    aria-label={isEdit ? "Modifier l'employé" : 'Ajouter un employé'}
  >
    <div class="flex items-center justify-between px-5 py-4 border-b border-border">
      <div class="text-[16px] font-bold text-dt-text">
        {isEdit ? "Modifier l'employé" : 'Ajouter un employé'}
      </div>
      <button
        onclick={onClose}
        aria-label="Fermer"
        class="text-dt-text-muted hover:text-dt-text transition-colors duration-[130ms]"
      >
        <Icon name="x" size={18} />
      </button>
    </div>

    <Form
      id="employee-form"
      schema={employeeFormSchema}
      onSubmit={handleSubmit}
      class="flex-1 flex flex-col min-h-0"
    >
      {#snippet children({errors, isValid, isSubmitting})}
        <div class="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-6">
          <div class="grid grid-cols-2 gap-4">
            {@render field('firstName', 'Prénom', errors.firstName, employee?.firstName)}
            {@render field('lastName', 'Nom', errors.lastName, employee?.lastName)}
          </div>

          <Select
            id="role"
            name="role"
            label="Rôle"
            options={employeeRoleOptions}
            bind:value={role}
            error={errors.role}
          />

          {@render field(
            'phoneNumber',
            'Téléphone',
            errors.phoneNumber,
            employee?.phoneNumber ?? ''
          )}
          {@render field('address', 'Adresse', errors.address, employee?.address ?? '')}
          {@render field(
            'hireDate',
            "Date d'embauche",
            errors.hireDate,
            employee?.hireDate ?? '',
            'date'
          )}

          <Select
            id="status"
            name="status"
            label="Statut"
            options={employeeStatusOptions}
            value={employee?.status ?? 'active'}
            error={errors.status}
          />

          {#if role === 'driver'}
            <Select
              id="truckId"
              name="truckId"
              label="Camion assigné"
              options={trucks.map((t) => ({value: t.id, label: t.plateNumber}))}
              value={employee?.assignedTruck?.id ?? ''}
              placeholder="Non affecté"
              error={errors.truckId}
            />
          {/if}

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
            {#if isSubmitting}
              {isEdit ? 'Enregistrement...' : 'Création...'}
            {:else}
              {isEdit ? 'Enregistrer' : "Créer l'employé"}
            {/if}
          </button>
        </div>
      {/snippet}
    </Form>
  </div>
{/if}
