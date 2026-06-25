import {render, fireEvent} from '@testing-library/svelte';
import {createRawSnippet} from 'svelte';
import userEvent from '@testing-library/user-event';
import Button from '$lib/components/common/Button.svelte';

function makeSnippet(text: string) {
  return createRawSnippet(() => ({render: () => `<span>${text}</span>`}));
}

describe('Button', () => {
  describe('primary variant (default)', () => {
    it('renders a button element', () => {
      const {getByRole} = render(Button, {children: makeSnippet('Click me')});
      expect(getByRole('button')).toBeInTheDocument();
    });

    it('renders children text', () => {
      const {getByRole} = render(Button, {children: makeSnippet('Click me')});
      expect(getByRole('button')).toHaveTextContent('Click me');
    });

    it('has default type of "button"', () => {
      const {getByRole} = render(Button, {children: makeSnippet('Click')});
      expect(getByRole('button')).toHaveAttribute('type', 'button');
    });

    it('accepts type="submit"', () => {
      const {getByRole} = render(Button, {type: 'submit', children: makeSnippet('Submit')});
      expect(getByRole('button')).toHaveAttribute('type', 'submit');
    });

    it('accepts type="reset"', () => {
      const {getByRole} = render(Button, {type: 'reset', children: makeSnippet('Reset')});
      expect(getByRole('button')).toHaveAttribute('type', 'reset');
    });

    it('is not disabled by default', () => {
      const {getByRole} = render(Button, {children: makeSnippet('Click')});
      expect(getByRole('button')).not.toBeDisabled();
    });

    it('is disabled when disabled prop is true', () => {
      const {getByRole} = render(Button, {disabled: true, children: makeSnippet('Click')});
      expect(getByRole('button')).toBeDisabled();
    });

    it('has the rounded-lg and text-white classes', () => {
      const {getByRole} = render(Button, {children: makeSnippet('Click')});
      const btn = getByRole('button');
      expect(btn).toHaveClass('rounded-lg');
      expect(btn).toHaveClass('text-white');
    });

    it('applies extra attributes via spread', () => {
      const {getByRole} = render(Button, {
        children: makeSnippet('Click'),
        'data-custom': 'value',
      });
      expect(getByRole('button')).toHaveAttribute('data-custom', 'value');
    });
  });

  describe('ghost variant', () => {
    it('renders a button element', () => {
      const {getByRole} = render(Button, {variant: 'ghost', children: makeSnippet('Ghost')});
      expect(getByRole('button')).toBeInTheDocument();
    });

    it('has hover:underline class', () => {
      const {getByRole} = render(Button, {variant: 'ghost', children: makeSnippet('Ghost')});
      expect(getByRole('button')).toHaveClass('hover:underline');
    });

    it('is disabled when disabled prop is true', () => {
      const {getByRole} = render(Button, {
        variant: 'ghost',
        disabled: true,
        children: makeSnippet('Ghost'),
      });
      expect(getByRole('button')).toBeDisabled();
    });
  });

  describe('unknown variant', () => {
    it('renders nothing', () => {
      const {queryByRole} = render(Button, {
        variant: 'unknown' as never,
        children: makeSnippet('X'),
      });
      expect(queryByRole('button')).not.toBeInTheDocument();
    });
  });

  describe('interactions', () => {
    it('calls onclick when clicked', async () => {
      const onclick = vi.fn();
      const {getByRole} = render(Button, {onclick, children: makeSnippet('Click')});
      await fireEvent.click(getByRole('button'));
      expect(onclick).toHaveBeenCalledOnce();
    });

    it('does not call onclick when disabled', async () => {
      const user = userEvent.setup();
      const onclick = vi.fn();
      const {getByRole} = render(Button, {
        disabled: true,
        onclick,
        children: makeSnippet('Click'),
      });
      await user.click(getByRole('button'));
      expect(onclick).not.toHaveBeenCalled();
    });
  });
});
