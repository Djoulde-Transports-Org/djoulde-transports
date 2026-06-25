import {render, fireEvent} from '@testing-library/svelte';
import PasswordInput from '$lib/components/common/PasswordInput.svelte';

const baseProps = {id: 'password', name: 'password', label: 'Password'};

describe('PasswordInput', () => {
  describe('rendering', () => {
    it('renders a label with the correct text', () => {
      const {getByText} = render(PasswordInput, baseProps);
      expect(getByText('Password')).toBeInTheDocument();
    });

    it('label is associated with input via htmlFor', () => {
      const {getByLabelText} = render(PasswordInput, baseProps);
      expect(getByLabelText('Password')).toBeInTheDocument();
    });

    it('input has correct id and name attributes', () => {
      const {getByLabelText} = render(PasswordInput, baseProps);
      const input = getByLabelText('Password');
      expect(input).toHaveAttribute('id', 'password');
      expect(input).toHaveAttribute('name', 'password');
    });

    it('renders placeholder text', () => {
      const {getByPlaceholderText} = render(PasswordInput, {
        ...baseProps,
        placeholder: 'Enter your password',
      });
      expect(getByPlaceholderText('Enter your password')).toBeInTheDocument();
    });

    it('sets autocomplete attribute', () => {
      const {getByLabelText} = render(PasswordInput, {
        ...baseProps,
        autocomplete: 'current-password',
      });
      expect(getByLabelText('Password')).toHaveAttribute('autocomplete', 'current-password');
    });
  });

  describe('password visibility toggle', () => {
    it('input type is password by default', () => {
      const {getByLabelText} = render(PasswordInput, baseProps);
      expect(getByLabelText('Password')).toHaveAttribute('type', 'password');
    });

    it('toggle button shows "Show password" label by default', () => {
      const {getByRole} = render(PasswordInput, baseProps);
      expect(getByRole('button', {name: 'Show password'})).toBeInTheDocument();
    });

    it('clicking toggle changes input type to text', async () => {
      const {getByRole, getByLabelText} = render(PasswordInput, baseProps);
      await fireEvent.click(getByRole('button', {name: 'Show password'}));
      expect(getByLabelText('Password')).toHaveAttribute('type', 'text');
    });

    it('toggle button aria-label changes to "Hide password" after reveal', async () => {
      const {getByRole} = render(PasswordInput, baseProps);
      await fireEvent.click(getByRole('button', {name: 'Show password'}));
      expect(getByRole('button', {name: 'Hide password'})).toBeInTheDocument();
    });

    it('clicking toggle again changes type back to password', async () => {
      const {getByRole, getByLabelText} = render(PasswordInput, baseProps);
      await fireEvent.click(getByRole('button', {name: 'Show password'}));
      await fireEvent.click(getByRole('button', {name: 'Hide password'}));
      expect(getByLabelText('Password')).toHaveAttribute('type', 'password');
    });

    it('"Show password" label is restored after hiding again', async () => {
      const {getByRole} = render(PasswordInput, baseProps);
      await fireEvent.click(getByRole('button', {name: 'Show password'}));
      await fireEvent.click(getByRole('button', {name: 'Hide password'}));
      expect(getByRole('button', {name: 'Show password'})).toBeInTheDocument();
    });
  });

  describe('without error', () => {
    it('label has text-gray-700 class', () => {
      const {getByText} = render(PasswordInput, baseProps);
      expect(getByText('Password')).toHaveClass('text-gray-700');
    });

    it('input has border-gray-300 class', () => {
      const {getByLabelText} = render(PasswordInput, baseProps);
      expect(getByLabelText('Password')).toHaveClass('border-gray-300');
    });

    it('shows no error message when error is undefined', () => {
      const {container} = render(PasswordInput, baseProps);
      expect(container.querySelector('p')).not.toBeInTheDocument();
    });

    it('shows no error message when error is null', () => {
      const {container} = render(PasswordInput, {...baseProps, error: null});
      expect(container.querySelector('p')).not.toBeInTheDocument();
    });
  });

  describe('with error as string', () => {
    it('shows the error message', () => {
      const {getByText} = render(PasswordInput, {...baseProps, error: 'Too short'});
      expect(getByText('Too short')).toBeInTheDocument();
    });

    it('label has text-red-600 class', () => {
      const {getByText} = render(PasswordInput, {...baseProps, error: 'Too short'});
      expect(getByText('Password')).toHaveClass('text-red-600');
    });

    it('input has border-red-500 class', () => {
      const {getByLabelText} = render(PasswordInput, {...baseProps, error: 'Too short'});
      expect(getByLabelText('Password')).toHaveClass('border-red-500');
    });
  });

  describe('with error as array', () => {
    it('shows the first error message', () => {
      const {getByText} = render(PasswordInput, {
        ...baseProps,
        error: ['Too short', 'Other error'],
      });
      expect(getByText('Too short')).toBeInTheDocument();
    });

    it('does not show the second error message', () => {
      const {queryByText} = render(PasswordInput, {
        ...baseProps,
        error: ['Too short', 'Other error'],
      });
      expect(queryByText('Other error')).not.toBeInTheDocument();
    });
  });
});
