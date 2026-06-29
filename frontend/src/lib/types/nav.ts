import type {IconName} from '$lib/components/common/Icon.svelte';

export type NavHref =
  | '/dashboard'
  | '/flotte'
  | '/employes'
  | '/trajets'
  | '/maintenance'
  | '/facturation'
  | '/documents';

export type NavItem = {
  label: string;
  href: NavHref;
  icon: IconName;
};
