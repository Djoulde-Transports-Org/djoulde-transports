<script lang="ts">
  import Sidebar from '$lib/components/layout/Sidebar.svelte';
  import type {Snippet} from 'svelte';
  import {onMount} from 'svelte';
  import {goto} from '$app/navigation';
  import {resolve} from '$app/paths';
  import {page} from '$app/stores';
  import {isAuthenticated} from '$lib/store/session/auth';
  import {validateSession} from '$lib/api/sessions';

  let {children}: {children: Snippet} = $props();

  $effect(() => {
    if (!$isAuthenticated) {
      // Query param appended to resolved path - resolve() cannot be the direct argument here
      // eslint-disable-next-line svelte/no-navigation-without-resolve
      goto(`${resolve('/login')}?redirect=${encodeURIComponent($page.url.pathname)}`);
    }
  });

  onMount(() => {
    // Verify the stored token is still valid server-side.
    // A 401 response is handled by client.ts which clears the session and redirects.
    // Network errors (server down) are ignored so users aren't logged out by a temporary outage.
    validateSession().catch(() => {});
  });
</script>

{#if $isAuthenticated}
  <div class="flex min-h-screen bg-ground">
    <Sidebar />
    <main class="ml-[224px] flex-1 min-w-0 overflow-y-auto min-h-screen">
      {@render children()}
    </main>
  </div>
{/if}
