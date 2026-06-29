import type {NavItem} from '$lib/types/nav';
import type {Role} from '$lib/types/session';

export const navItems: NavItem[] = [
  {label: 'Tableau de bord', href: '/dashboard', icon: 'dashboard'},
  {label: 'Flotte', href: '/flotte', icon: 'truck'},
  {label: 'Employés', href: '/employes', icon: 'users'},
  {label: 'Trajets', href: '/trajets', icon: 'navigation'},
  {label: 'Maintenance', href: '/maintenance', icon: 'wrench'},
  {label: 'Facturation', href: '/facturation', icon: 'receipt'},
  {label: 'Documents', href: '/documents', icon: 'folder'},
];

export const roleLabels: Record<Role, string> = {
  super_admin: 'Super Admin',
  dispatcher: 'Dispatcher',
  billing: 'Facturation',
  maintenance: 'Maintenance',
  driver_readonly: 'Chauffeur',
};
