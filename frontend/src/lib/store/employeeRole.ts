import type {EmployeeRole} from '$lib/types/employee';

export const employeeRoleMeta: Record<EmployeeRole, {label: string; classes: string}> = {
  driver: {label: 'Chauffeur', classes: 'bg-accent/10 text-accent border-accent/20'},
  mechanic: {label: 'Technicien', classes: 'bg-dt-yellow/10 text-dt-yellow border-dt-yellow/20'},
  dispatcher: {label: 'Dispatcher', classes: 'bg-surface-2 text-dt-text-muted border-border'},
  manager: {label: 'Admin', classes: 'bg-surface-2 text-dt-text-muted border-border'},
};
