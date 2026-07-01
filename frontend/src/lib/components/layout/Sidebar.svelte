<script lang="ts">
  import {page} from '$app/stores';
  import {resolve} from '$app/paths';
  import {goto} from '$app/navigation';
  import {authStore} from '$lib/store/session/auth';
  import {navItems, roleLabels} from '$lib/store/nav';
  import {logout} from '$lib/api/sessions';

  import Icon from '$lib/components/common/Icon.svelte';
  import logo from '$lib/assets/djoulde-transport-logo.png';

  $: session = $authStore;
  $: primaryRole = session?.roles?.[0] ?? 'dispatcher';
  $: roleLabel = roleLabels[primaryRole] ?? primaryRole;
  $: initials = roleLabel.slice(0, 2).toUpperCase();
  $: activePath = $page.url.pathname;

  const handleLogout = async () => {
    await logout().catch(() => {});
    authStore.clearSession();
    goto(resolve('/login'));
  };
</script>

<nav
  class="fixed top-0 left-0 w-[224px] h-screen flex flex-col justify-between bg-ground border-r border-border z-40"
>
  <div class="flex flex-col overflow-y-auto">
    <!-- Brand -->
    <div class="flex items-center px-4 py-4 border-b border-border">
      <img src={logo} alt="Djoulde Transports" class="h-14 w-auto object-contain" />
    </div>

    <!-- Nav -->
    <ul class="list-none py-2.5 flex flex-col gap-0.5 m-0 p-0">
      {#each navItems as item (item.href)}
        {@const itemPath = resolve(item.href)}
        {@const active = activePath === itemPath || activePath.startsWith(itemPath + '/')}
        <li>
          <a
            href={itemPath}
            class="flex items-center gap-2.5 px-4 py-[9px] text-[13px] no-underline relative transition-colors duration-[130ms]
              {active
              ? 'text-dt-text bg-surface font-semibold'
              : 'text-dt-text-muted font-medium hover:text-dt-text hover:bg-surface'}"
          >
            {#if active}
              <span class="absolute left-0 top-1.5 bottom-1.5 w-[3px] bg-accent rounded-r-sm"
              ></span>
            {/if}
            <Icon name={item.icon} size={16} class="shrink-0" />
            <span>{item.label}</span>
          </a>
        </li>
      {/each}
    </ul>
  </div>

  <!-- User row -->
  <div class="flex items-center gap-2.5 px-4 py-3.5 border-t border-border">
    <div
      class="w-8 h-8 rounded-full bg-surface-2 border border-border flex items-center justify-center text-[10px] font-black text-accent tracking-wider shrink-0"
    >
      {initials}
    </div>
    <div class="flex flex-col gap-0 min-w-0 flex-1">
      <span class="text-[12px] font-semibold text-dt-text-mid truncate">
        Utilisateur #{session?.user_id ?? '—'}
      </span>
      <span class="text-[11px] text-dt-text-muted">{roleLabel}</span>
    </div>
    <button
      onclick={handleLogout}
      class="transition-colors duration-[130ms] shrink-0"
      title="Se déconnecter"
    >
      <Icon name="logout" size={15} class="text-accent hover:text-accent/80 cursor-pointer" />
    </button>
  </div>
</nav>
