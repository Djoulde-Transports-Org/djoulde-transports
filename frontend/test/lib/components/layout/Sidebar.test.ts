import {render, fireEvent, waitFor} from '@testing-library/svelte';
import {writable} from 'svelte/store';
import {authStore} from '$lib/store/session/auth';
import Sidebar from '$lib/components/layout/Sidebar.svelte';
import type {Session} from '$lib/types/session';
import {goto} from '$app/navigation';
import {logout} from '$lib/api/sessions';

vi.mock('$app/paths', () => ({resolve: (path: string) => path}));
vi.mock('$app/stores', () => ({
  page: writable({url: {pathname: '/dashboard'}}),
}));
vi.mock('$app/environment', () => ({browser: true}));
vi.mock('$app/navigation', () => ({goto: vi.fn()}));
vi.mock('$lib/api/sessions', () => ({
  logout: vi.fn().mockResolvedValue(undefined),
}));

const makeSession = (overrides?: Partial<Session>): Session => ({
  access_token: 'tok_abc',
  token_type: 'Bearer',
  expires_in: 7200,
  created_at: 1700000000,
  user_id: 42,
  roles: ['dispatcher'],
  ...overrides,
});

describe('Sidebar', () => {
  beforeEach(() => {
    authStore.clearSession();
    vi.clearAllMocks();
  });

  describe('brand', () => {
    it('renders the logo image', () => {
      const {getByAltText} = render(Sidebar);
      expect(getByAltText('Djoulde Transports')).toBeInTheDocument();
    });
  });

  describe('navigation', () => {
    it('renders all 7 nav links', () => {
      const {getAllByRole} = render(Sidebar);
      const links = getAllByRole('link');
      expect(links).toHaveLength(7);
    });

    it('renders the correct nav labels', () => {
      const {getByText} = render(Sidebar);
      expect(getByText('Tableau de bord')).toBeInTheDocument();
      expect(getByText('Flotte')).toBeInTheDocument();
      expect(getByText('Employés')).toBeInTheDocument();
      expect(getByText('Trajets')).toBeInTheDocument();
      expect(getByText('Maintenance')).toBeInTheDocument();
      expect(getByText('Facturation')).toBeInTheDocument();
      expect(getByText('Documents')).toBeInTheDocument();
    });

    it('links point to the correct hrefs', () => {
      const {getByText} = render(Sidebar);
      expect(getByText('Tableau de bord').closest('a')).toHaveAttribute('href', '/dashboard');
      expect(getByText('Flotte').closest('a')).toHaveAttribute('href', '/flotte');
    });

    it('marks the active route with an indicator', () => {
      const {container} = render(Sidebar);
      const activeLink = container.querySelector('a[href="/dashboard"]')!;
      expect(activeLink).toHaveClass('bg-surface');
      expect(activeLink.querySelector('span.bg-accent')).toBeInTheDocument();
    });

    it('inactive links do not have the active indicator', () => {
      const {container} = render(Sidebar);
      const inactiveLink = container.querySelector('a[href="/flotte"]')!;
      expect(inactiveLink.querySelector('span.bg-accent')).not.toBeInTheDocument();
    });
  });

  describe('user row — unauthenticated', () => {
    it('shows the fallback user id', () => {
      const {getByText} = render(Sidebar);
      expect(getByText(/Utilisateur #—/)).toBeInTheDocument();
    });
  });

  describe('user row — authenticated', () => {
    it('shows the user id', () => {
      authStore.setSession(makeSession({user_id: 42}));
      const {getByText} = render(Sidebar);
      expect(getByText('Utilisateur #42')).toBeInTheDocument();
    });

    it('shows the role label', () => {
      authStore.setSession(makeSession({roles: ['dispatcher']}));
      const {getByText} = render(Sidebar);
      expect(getByText('Dispatcher')).toBeInTheDocument();
    });

    it('derives initials from the role label', () => {
      authStore.setSession(makeSession({roles: ['super_admin']}));
      const {getByText} = render(Sidebar);
      expect(getByText('SU')).toBeInTheDocument();
    });

    it('uses the first role when the session has multiple roles', () => {
      authStore.setSession(makeSession({roles: ['billing', 'dispatcher']}));
      const {container} = render(Sidebar);
      const roleSpan = container.querySelector('span.text-dt-text-muted');
      expect(roleSpan).toHaveTextContent('Facturation');
    });
  });

  describe('sign out', () => {
    it('renders the logout button', () => {
      const {getByTitle} = render(Sidebar);
      expect(getByTitle('Se déconnecter')).toBeInTheDocument();
    });

    it('calls logout() when clicked', async () => {
      const {getByTitle} = render(Sidebar);
      fireEvent.click(getByTitle('Se déconnecter'));
      await waitFor(() => expect(logout).toHaveBeenCalledOnce());
    });

    it('clears the session after logout', async () => {
      authStore.setSession(makeSession());
      const clearSpy = vi.spyOn(authStore, 'clearSession');
      const {getByTitle} = render(Sidebar);
      fireEvent.click(getByTitle('Se déconnecter'));
      await waitFor(() => expect(clearSpy).toHaveBeenCalledOnce());
    });

    it('navigates to /login after logout', async () => {
      const {getByTitle} = render(Sidebar);
      fireEvent.click(getByTitle('Se déconnecter'));
      await waitFor(() => expect(goto).toHaveBeenCalledWith('/login'));
    });

    it('still clears the session and navigates when logout() fails', async () => {
      vi.mocked(logout).mockRejectedValueOnce(new Error('network error'));
      const clearSpy = vi.spyOn(authStore, 'clearSession');
      const {getByTitle} = render(Sidebar);
      fireEvent.click(getByTitle('Se déconnecter'));
      await waitFor(() => {
        expect(clearSpy).toHaveBeenCalledOnce();
        expect(goto).toHaveBeenCalledWith('/login');
      });
    });
  });
});
