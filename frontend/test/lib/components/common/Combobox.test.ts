import {render, fireEvent, waitFor} from '@testing-library/svelte';
import Combobox from '$lib/components/common/Combobox.svelte';

const baseProps = {
  id: 'driver_id',
  name: 'driver_id',
  label: 'Affectation',
  options: [
    {value: 1, label: 'Ibrahima Bah'},
    {value: 2, label: 'Mamadou Diallo'},
  ],
};

describe('Combobox', () => {
  describe('rendering', () => {
    it('renders a label with the correct text', () => {
      const {getByText} = render(Combobox, baseProps);
      expect(getByText('Affectation')).toBeInTheDocument();
    });

    it('label is associated with the input via htmlFor', () => {
      const {getByLabelText} = render(Combobox, baseProps);
      expect(getByLabelText('Affectation')).toBeInTheDocument();
    });

    it('renders a hidden input with the given name and an empty value', () => {
      const {container} = render(Combobox, baseProps);
      const hidden = container.querySelector('input[type="hidden"]');
      expect(hidden).toHaveAttribute('name', 'driver_id');
      expect(hidden).toHaveValue('');
    });

    it('shows the default empty label as placeholder when nothing is selected', () => {
      const {getByLabelText} = render(Combobox, baseProps);
      expect(getByLabelText('Affectation')).toHaveAttribute('placeholder', 'Aucune sélection');
    });

    it('shows a custom empty label as placeholder', () => {
      const {getByLabelText} = render(Combobox, {
        ...baseProps,
        emptyLabel: "Non affecté pour l'instant",
      });
      expect(getByLabelText('Affectation')).toHaveAttribute(
        'placeholder',
        "Non affecté pour l'instant"
      );
    });

    it('does not show the option list before the input is focused', () => {
      const {queryByText} = render(Combobox, baseProps);
      expect(queryByText('Ibrahima Bah')).not.toBeInTheDocument();
    });
  });

  describe('opening and filtering', () => {
    it('shows all options when the input is focused', async () => {
      const {getByLabelText, getByText} = render(Combobox, baseProps);
      await fireEvent.focus(getByLabelText('Affectation'));
      expect(getByText('Ibrahima Bah')).toBeInTheDocument();
      expect(getByText('Mamadou Diallo')).toBeInTheDocument();
    });

    it('filters options as text is typed', async () => {
      const {getByLabelText, getByText, queryByText} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.input(input, {target: {value: 'Ibra'}});
      expect(getByText('Ibrahima Bah')).toBeInTheDocument();
      expect(queryByText('Mamadou Diallo')).not.toBeInTheDocument();
    });

    it('filtering is case-insensitive', async () => {
      const {getByLabelText, getByText} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.input(input, {target: {value: 'ibra'}});
      expect(getByText('Ibrahima Bah')).toBeInTheDocument();
    });

    it('shows a no-results message when nothing matches', async () => {
      const {getByLabelText, getByText} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.input(input, {target: {value: 'zzz'}});
      expect(getByText('Aucun résultat')).toBeInTheDocument();
    });

    it('closes the list on Escape', async () => {
      const {getByLabelText, queryByText} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.keyDown(input, {key: 'Escape'});
      expect(queryByText('Ibrahima Bah')).not.toBeInTheDocument();
    });

    it('closes the list on blur', async () => {
      const {getByLabelText, queryByText} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.blur(input);
      expect(queryByText('Ibrahima Bah')).not.toBeInTheDocument();
    });
  });

  describe('selection', () => {
    it('sets the hidden input value when an option is chosen', async () => {
      const {getByLabelText, getByText, container} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.mouseDown(getByText('Ibrahima Bah'));
      const hidden = container.querySelector('input[type="hidden"]');
      expect(hidden).toHaveValue('1');
    });

    it('displays the chosen option label after closing', async () => {
      const {getByLabelText, getByText} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.mouseDown(getByText('Ibrahima Bah'));
      await fireEvent.blur(input);
      expect(input).toHaveValue('Ibrahima Bah');
    });

    it('clears the selection when the empty option is chosen', async () => {
      const {getByLabelText, getByText, container} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.mouseDown(getByText('Ibrahima Bah'));
      await fireEvent.focus(input);
      await fireEvent.mouseDown(getByText('Aucune sélection'));
      const hidden = container.querySelector('input[type="hidden"]');
      expect(hidden).toHaveValue('');
    });

    it('closes the list after choosing an option', async () => {
      const {getByLabelText, getByText, queryByText} = render(Combobox, baseProps);
      const input = getByLabelText('Affectation');
      await fireEvent.focus(input);
      await fireEvent.mouseDown(getByText('Mamadou Diallo'));
      await waitFor(() => expect(queryByText('Ibrahima Bah')).not.toBeInTheDocument());
    });
  });

  describe('errors', () => {
    it('shows no error message when error is undefined', () => {
      const {container} = render(Combobox, baseProps);
      expect(container.querySelector('p')).not.toBeInTheDocument();
    });

    it('shows no error message when error is null', () => {
      const {container} = render(Combobox, {...baseProps, error: null});
      expect(container.querySelector('p')).not.toBeInTheDocument();
    });

    it('shows the error message when error is a string', () => {
      const {getByText} = render(Combobox, {...baseProps, error: 'Chauffeur invalide'});
      expect(getByText('Chauffeur invalide')).toBeInTheDocument();
    });

    it('shows only the first message when error is an array', () => {
      const {getByText, queryByText} = render(Combobox, {
        ...baseProps,
        error: ['First error', 'Second error'],
      });
      expect(getByText('First error')).toBeInTheDocument();
      expect(queryByText('Second error')).not.toBeInTheDocument();
    });

    it('applies the error border class to the input', () => {
      const {getByLabelText} = render(Combobox, {...baseProps, error: 'Chauffeur invalide'});
      expect(getByLabelText('Affectation')).toHaveClass('border-dt-red');
    });
  });
});
