<script lang="ts">
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

  beforeNavigate(({to, cancel}) => {
    if (!to?.url.pathname) return;
    const isPublic = PUBLIC_ROUTES.includes(to.url.pathname);
    if (!get(isAuthenticated) && !isPublic) {
      cancel();
      loginWithRedirect(to.url.pathname);
    } else if (get(isAuthenticated) && isPublic) {
      cancel();
      goto(resolve('/dashboard'));
    }
  });
</script>

{@render children()}
