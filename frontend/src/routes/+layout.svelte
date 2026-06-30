<script lang="ts">
  import {onMount} from 'svelte';
  import {page} from '$app/stores';
  import {goto, beforeNavigate} from '$app/navigation';
  import {resolve} from '$app/paths';
  import {get} from 'svelte/store';
  import {isAuthenticated} from '$lib/store/session/auth';
  import '../app.css';
  import type {Snippet} from 'svelte';

  let {children}: {children: Snippet} = $props();

  const PUBLIC_ROUTES = ['/login'];

  const loginWithRedirect = (path: string) => {
    // Query param appended to resolved path - resolve() cannot be the direct argument here
    // eslint-disable-next-line svelte/no-navigation-without-resolve
    goto(`${resolve('/login')}?redirect=${encodeURIComponent(path)}`);
  };

  const guard = (path: string, cancel: (() => void) | undefined = undefined) => {
    const isPublic = PUBLIC_ROUTES.includes(path);
    if (!get(isAuthenticated) && !isPublic) {
      cancel?.();
      loginWithRedirect(path);
    } else if (get(isAuthenticated) && isPublic) {
      cancel?.();
      goto(resolve('/dashboard'));
    }
  };

  onMount(() => guard(get(page).url.pathname));

  beforeNavigate(({to, cancel}) => {
    if (to?.url.pathname) guard(to.url.pathname, cancel);
  });
</script>

{@render children()}
