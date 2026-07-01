import {render, waitFor} from '@testing-library/svelte';
import userEvent from '@testing-library/user-event';
import {writable} from 'svelte/store';
import SignInForm from '$lib/components/session/SignInForm.svelte';
import type {Session} from '$lib/types/session';

vi.mock('$lib/api/sessions', () => ({login: vi.fn()}));
vi.mock('$app/navigation', () => ({goto: vi.fn().mockResolvedValue(undefined)}));
vi.mock('$app/paths', () => ({resolve: (path: string) => path}));
vi.mock('$app/stores', async () => {
  const {writable} = await import('svelte/store');
  return {page: writable({url: new URL('http://localhost/login')})};
});

import {login} from '$lib/api/sessions';
import {goto} from '$app/navigation';
import {page} from '$app/stores';
import {authStore} from '$lib/store/session/auth';

const makeSession = (roles: Session['roles'] = ['dispatcher']): Session => ({
  access_token: 'tok_test',
  token_type: 'Bearer',
  expires_in: 7200,
  created_at: 1700000000,
  user_id: 1,
  roles,
});

describe('SignInForm', () => {
  describe('rendering', () => {
    it('renders the "Sign in to your account" header', () => {
      const {getByTestId} = render(SignInForm);
      expect(getByTestId('welcome-message')).toHaveTextContent('Sign in to your account');
    });

    it('renders the email input', () => {
      const {getByLabelText} = render(SignInForm);
      expect(getByLabelText('Email')).toBeInTheDocument();
    });

    it('email input has type email', () => {
      const {getByLabelText} = render(SignInForm);
      expect(getByLabelText('Email')).toHaveAttribute('type', 'email');
    });

    it('email input has correct autocomplete', () => {
      const {getByLabelText} = render(SignInForm);
      expect(getByLabelText('Email')).toHaveAttribute('autocomplete', 'email');
    });

    it('renders the password input', () => {
      const {getByLabelText} = render(SignInForm);
      expect(getByLabelText('Password')).toBeInTheDocument();
    });

    it('password input type is password by default', () => {
      const {getByLabelText} = render(SignInForm);
      expect(getByLabelText('Password')).toHaveAttribute('type', 'password');
    });

    it('renders the sign in button', () => {
      const {getByRole} = render(SignInForm);
      expect(getByRole('button', {name: 'Sign in'})).toBeInTheDocument();
    });

    it('sign in button is a submit button', () => {
      const {getByRole} = render(SignInForm);
      expect(getByRole('button', {name: 'Sign in'})).toHaveAttribute('type', 'submit');
    });

    it('renders the "Forgot password?" button', () => {
      const {getByRole} = render(SignInForm);
      expect(getByRole('button', {name: 'Forgot password?'})).toBeInTheDocument();
    });

    it('"Forgot password?" button is of type button', () => {
      const {getByRole} = render(SignInForm);
      expect(getByRole('button', {name: 'Forgot password?'})).toHaveAttribute('type', 'button');
    });
  });

  describe('initial state', () => {
    it('sign in button is enabled before user interaction (felte does not validate on mount)', () => {
      const {getByRole} = render(SignInForm);
      // felte initializes isValid=true before any field is touched
      expect(getByRole('button', {name: 'Sign in'})).not.toBeDisabled();
    });

    it('"Forgot password?" button is always enabled', () => {
      const {getByRole} = render(SignInForm);
      expect(getByRole('button', {name: 'Forgot password?'})).not.toBeDisabled();
    });
  });

  describe('validation-driven interactions', () => {
    it('sign in button becomes enabled after entering valid email and password', async () => {
      const user = userEvent.setup();
      const {getByLabelText, getByRole} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'test@example.com');
      await user.type(getByLabelText('Password'), 'password123');

      await waitFor(
        () => {
          expect(getByRole('button', {name: 'Sign in'})).not.toBeDisabled();
        },
        {timeout: 2000}
      );
    });

    it('sign in button stays disabled with invalid email', async () => {
      const user = userEvent.setup();
      const {getByLabelText, getByRole} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'not-an-email');
      await user.type(getByLabelText('Password'), 'password123');

      await new Promise((r) => setTimeout(r, 200));
      expect(getByRole('button', {name: 'Sign in'})).toBeDisabled();
    });

    it('sign in button stays disabled with short password', async () => {
      const user = userEvent.setup();
      const {getByLabelText, getByRole} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'test@example.com');
      await user.type(getByLabelText('Password'), '123');

      await new Promise((r) => setTimeout(r, 200));
      expect(getByRole('button', {name: 'Sign in'})).toBeDisabled();
    });

    it('password can be revealed via toggle', async () => {
      const user = userEvent.setup();
      const {getByLabelText, getByRole} = render(SignInForm);

      await user.click(getByRole('button', {name: 'Show password'}));
      expect(getByLabelText('Password')).toHaveAttribute('type', 'text');
    });
  });

  describe('post-login redirect', () => {
    let locationMock: {href: string};

    beforeEach(() => {
      locationMock = {href: ''};
      vi.stubGlobal('location', locationMock);
      vi.mocked(goto).mockResolvedValue(undefined);
      vi.mocked(login).mockReset();
      (page as ReturnType<typeof writable>).set({url: new URL('http://localhost/login')});
    });

    afterEach(() => {
      vi.unstubAllGlobals();
      authStore.clearSession();
    });

    it('redirects to /dashboard for non-super_admin with no redirect param', async () => {
      const user = userEvent.setup();
      vi.mocked(login).mockResolvedValueOnce(makeSession(['dispatcher']));
      const {getByLabelText, getByRole} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'test@example.com');
      await user.type(getByLabelText('Password'), 'password123');
      await user.click(getByRole('button', {name: 'Sign in'}));

      await waitFor(() => expect(goto).toHaveBeenCalledWith('/dashboard', {replaceState: true}));
    });

    it('sets window.location.href to /admin for super_admin', async () => {
      const user = userEvent.setup();
      vi.mocked(login).mockResolvedValueOnce(makeSession(['super_admin']));
      const {getByLabelText, getByRole} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'test@example.com');
      await user.type(getByLabelText('Password'), 'password123');
      await user.click(getByRole('button', {name: 'Sign in'}));

      await waitFor(() => expect(locationMock.href).toBe('/admin'));
    });

    it('redirects to a valid app route from the redirect param', async () => {
      const user = userEvent.setup();
      vi.mocked(login).mockResolvedValueOnce(makeSession(['dispatcher']));
      (page as ReturnType<typeof writable>).set({
        url: new URL('http://localhost/login?redirect=%2Fflotte'),
      });
      const {getByLabelText, getByRole} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'test@example.com');
      await user.type(getByLabelText('Password'), 'password123');
      await user.click(getByRole('button', {name: 'Sign in'}));

      await waitFor(() => expect(goto).toHaveBeenCalledWith('/flotte', {replaceState: true}));
    });

    it('ignores a redirect param that is not a known app route', async () => {
      const user = userEvent.setup();
      vi.mocked(login).mockResolvedValueOnce(makeSession(['dispatcher']));
      (page as ReturnType<typeof writable>).set({
        url: new URL('http://localhost/login?redirect=%2Fevil'),
      });
      const {getByLabelText, getByRole} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'test@example.com');
      await user.type(getByLabelText('Password'), 'password123');
      await user.click(getByRole('button', {name: 'Sign in'}));

      await waitFor(() => expect(goto).toHaveBeenCalledWith('/dashboard', {replaceState: true}));
    });

    it('shows error message when login fails', async () => {
      const user = userEvent.setup();
      vi.mocked(login).mockRejectedValueOnce(new Error('Invalid credentials'));
      const {getByLabelText, getByRole, findByText} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'test@example.com');
      await user.type(getByLabelText('Password'), 'password123');
      await user.click(getByRole('button', {name: 'Sign in'}));

      expect(await findByText('Invalid credentials')).toBeInTheDocument();
    });

    it('clears error message on a successful retry', async () => {
      const user = userEvent.setup();
      vi.mocked(login)
        .mockRejectedValueOnce(new Error('Invalid credentials'))
        .mockResolvedValueOnce(makeSession());
      const {getByLabelText, getByRole, findByText, queryByText} = render(SignInForm);

      await user.type(getByLabelText('Email'), 'test@example.com');
      await user.type(getByLabelText('Password'), 'password123');
      await user.click(getByRole('button', {name: 'Sign in'}));
      await findByText('Invalid credentials');

      await user.click(getByRole('button', {name: 'Sign in'}));
      await waitFor(() => expect(queryByText('Invalid credentials')).not.toBeInTheDocument());
    });
  });
});
