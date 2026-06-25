import {render, waitFor} from '@testing-library/svelte';
import userEvent from '@testing-library/user-event';
import SignInForm from '$lib/components/session/SignInForm.svelte';

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
});
