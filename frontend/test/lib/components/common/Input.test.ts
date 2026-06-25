import {render} from '@testing-library/svelte';
import Input from '$lib/components/common/Input.svelte';

const baseProps = {id: 'email', name: 'email', label: 'Email'};

describe('Input', () => {
  describe('rendering', () => {
    it('renders a label with the correct text', () => {
      const {getByText} = render(Input, baseProps);
      expect(getByText('Email')).toBeInTheDocument();
    });

    it('label is associated with input via htmlFor', () => {
      const {getByLabelText} = render(Input, baseProps);
      expect(getByLabelText('Email')).toBeInTheDocument();
    });

    it('input has correct name attribute', () => {
      const {getByLabelText} = render(Input, baseProps);
      expect(getByLabelText('Email')).toHaveAttribute('name', 'email');
    });

    it('input has correct id attribute', () => {
      const {getByLabelText} = render(Input, baseProps);
      expect(getByLabelText('Email')).toHaveAttribute('id', 'email');
    });

    it('default type is text', () => {
      const {getByLabelText} = render(Input, baseProps);
      expect(getByLabelText('Email')).toHaveAttribute('type', 'text');
    });

    it('accepts a custom type', () => {
      const {getByLabelText} = render(Input, {...baseProps, type: 'email'});
      expect(getByLabelText('Email')).toHaveAttribute('type', 'email');
    });

    it('renders placeholder text', () => {
      const {getByPlaceholderText} = render(Input, {
        ...baseProps,
        placeholder: 'Enter your email',
      });
      expect(getByPlaceholderText('Enter your email')).toBeInTheDocument();
    });

    it('sets autocomplete attribute', () => {
      const {getByLabelText} = render(Input, {...baseProps, autocomplete: 'email'});
      expect(getByLabelText('Email')).toHaveAttribute('autocomplete', 'email');
    });

    it('does not set autocomplete when not provided', () => {
      const {getByLabelText} = render(Input, baseProps);
      expect(getByLabelText('Email')).not.toHaveAttribute('autocomplete');
    });
  });

  describe('without error', () => {
    it('label has text-gray-700 class', () => {
      const {getByText} = render(Input, baseProps);
      expect(getByText('Email')).toHaveClass('text-gray-700');
    });

    it('label does not have text-red-600 class', () => {
      const {getByText} = render(Input, baseProps);
      expect(getByText('Email')).not.toHaveClass('text-red-600');
    });

    it('input has border-gray-300 class', () => {
      const {getByLabelText} = render(Input, baseProps);
      expect(getByLabelText('Email')).toHaveClass('border-gray-300');
    });

    it('shows no error message when error is undefined', () => {
      const {container} = render(Input, baseProps);
      expect(container.querySelector('p')).not.toBeInTheDocument();
    });

    it('shows no error message when error is null', () => {
      const {container} = render(Input, {...baseProps, error: null});
      expect(container.querySelector('p')).not.toBeInTheDocument();
    });
  });

  describe('with error as string', () => {
    it('shows the error message', () => {
      const {getByText} = render(Input, {...baseProps, error: 'Invalid email'});
      expect(getByText('Invalid email')).toBeInTheDocument();
    });

    it('label has text-red-600 class', () => {
      const {getByText} = render(Input, {...baseProps, error: 'Invalid email'});
      expect(getByText('Email')).toHaveClass('text-red-600');
    });

    it('input has border-red-500 class', () => {
      const {getByLabelText} = render(Input, {...baseProps, error: 'Invalid email'});
      expect(getByLabelText('Email')).toHaveClass('border-red-500');
    });
  });

  describe('with error as array', () => {
    it('shows the first error message', () => {
      const {getByText} = render(Input, {
        ...baseProps,
        error: ['First error', 'Second error'],
      });
      expect(getByText('First error')).toBeInTheDocument();
    });

    it('does not show the second error message', () => {
      const {queryByText} = render(Input, {
        ...baseProps,
        error: ['First error', 'Second error'],
      });
      expect(queryByText('Second error')).not.toBeInTheDocument();
    });
  });
});
