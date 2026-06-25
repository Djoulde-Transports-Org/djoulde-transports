import {render, fireEvent, waitFor} from '@testing-library/svelte';
import {createRawSnippet} from 'svelte';
import * as yup from 'yup';
import Form from '$lib/components/common/Form.svelte';

const emptySchema = yup.object({});

function makeSnippet(html: string) {
  return createRawSnippet(() => ({render: () => html}));
}

describe('Form', () => {
  describe('structure', () => {
    it('renders a form element', () => {
      const {container} = render(Form, {
        schema: emptySchema,
        onSubmit: async () => {},
        children: makeSnippet('<span>Content</span>'),
      });
      expect(container.querySelector('form')).toBeInTheDocument();
    });

    it('sets the id attribute when provided', () => {
      const {container} = render(Form, {
        id: 'test-form',
        schema: emptySchema,
        onSubmit: async () => {},
        children: makeSnippet('<span>Content</span>'),
      });
      expect(container.querySelector('form')).toHaveAttribute('id', 'test-form');
    });

    it('sets data-testid="form-{id}" when id is provided', () => {
      const {getByTestId} = render(Form, {
        id: 'my-form',
        schema: emptySchema,
        onSubmit: async () => {},
        children: makeSnippet('<span>Content</span>'),
      });
      expect(getByTestId('form-my-form')).toBeInTheDocument();
    });

    it('does not set data-testid when id is not provided', () => {
      const {container} = render(Form, {
        schema: emptySchema,
        onSubmit: async () => {},
        children: makeSnippet('<span>Content</span>'),
      });
      expect(container.querySelector('[data-testid]')).not.toBeInTheDocument();
    });

    it('applies custom class to the form element', () => {
      const {container} = render(Form, {
        schema: emptySchema,
        onSubmit: async () => {},
        class: 'my-custom-class flex flex-col',
        children: makeSnippet('<span>Content</span>'),
      });
      expect(container.querySelector('form')).toHaveClass('my-custom-class');
    });

    it('renders children content inside the form', () => {
      const {getByText} = render(Form, {
        schema: emptySchema,
        onSubmit: async () => {},
        children: makeSnippet('<span>Test content</span>'),
      });
      expect(getByText('Test content')).toBeInTheDocument();
    });
  });

  describe('submission', () => {
    it('calls onSubmit when the form is submitted with valid data', async () => {
      const onSubmit = vi.fn().mockResolvedValue(undefined);
      const {container} = render(Form, {
        schema: emptySchema,
        onSubmit,
        children: makeSnippet('<button type="submit">Submit</button>'),
      });
      const form = container.querySelector('form')!;
      await fireEvent.submit(form);
      await waitFor(() => {
        expect(onSubmit).toHaveBeenCalledOnce();
      });
    });

    it('does not call onSubmit when validation fails', async () => {
      const strictSchema = yup.object({
        email: yup.string().email().required(),
      });
      const onSubmit = vi.fn().mockResolvedValue(undefined);
      const {container} = render(Form, {
        schema: strictSchema,
        onSubmit,
        children: makeSnippet('<button type="submit">Submit</button>'),
      });
      const form = container.querySelector('form')!;
      await fireEvent.submit(form);
      await new Promise((r) => setTimeout(r, 100));
      expect(onSubmit).not.toHaveBeenCalled();
    });
  });
});
