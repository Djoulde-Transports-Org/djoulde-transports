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

  const guard = (path: string) => {
    const isPublic = PUBLIC_ROUTES.includes(path);
    if (!get(isAuthenticated) && !isPublic) goto(resolve('/login'));
    else if (get(isAuthenticated) && isPublic) goto(resolve('/'));
  };

  onMount(() => guard($page.url.pathname));

  beforeNavigate(({to}) => {
    if (to?.url.pathname) guard(to.url.pathname);
  });
</script>

{@render children()}
