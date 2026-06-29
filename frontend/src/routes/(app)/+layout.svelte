<script lang="ts">
  import Sidebar from '$lib/components/layout/Sidebar.svelte';
  import type {Snippet} from 'svelte';

  let {children}: {children: Snippet} = $props();
</script>

<div class="flex min-h-screen bg-ground">
  <Sidebar />
  <main class="ml-[224px] flex-1 min-w-0 overflow-y-auto min-h-screen">
    {@render children()}
  </main>
</div>
