import {render} from '@testing-library/svelte';
import Select from '$lib/components/common/Select.svelte';

const baseProps = {
  id: 'driver_id',
  name: 'driver_id',
  label: 'Chauffeur',
  options: [
    {value: 1, label: 'Ibrahima Bah'},
    {value: 2, label: 'Mamadou Diallo'},
  ],
};

describe('Select', () => {
  describe('rendering', () => {
    it('renders a label with the correct text', () => {
      const {getByText} = render(Select, baseProps);
      expect(getByText('Chauffeur')).toBeInTheDocument();
    });

    it('label is associated with the select via htmlFor', () => {
      const {getByLabelText} = render(Select, baseProps);
      expect(getByLabelText('Chauffeur')).toBeInTheDocument();
    });

    it('select has correct name attribute', () => {
      const {getByLabelText} = render(Select, baseProps);
      expect(getByLabelText('Chauffeur')).toHaveAttribute('name', 'driver_id');
    });

    it('select has correct id attribute', () => {
      const {getByLabelText} = render(Select, baseProps);
      expect(getByLabelText('Chauffeur')).toHaveAttribute('id', 'driver_id');
    });

    it('renders an option per entry', () => {
      const {getByText} = render(Select, baseProps);
      expect(getByText('Ibrahima Bah')).toBeInTheDocument();
      expect(getByText('Mamadou Diallo')).toBeInTheDocument();
    });

    it('renders no options when the list is empty', () => {
      const {getByLabelText} = render(Select, {...baseProps, options: []});
      const select = getByLabelText('Chauffeur') as HTMLSelectElement;
      expect(select.options.length).toBe(1); // placeholder only
    });

    it('renders the default placeholder option', () => {
      const {getByText} = render(Select, baseProps);
      expect(getByText('Sélectionner...')).toBeInTheDocument();
    });

    it('renders a custom placeholder option', () => {
      const {getByText} = render(Select, {...baseProps, placeholder: 'Aucun chauffeur'});
      expect(getByText('Aucun chauffeur')).toBeInTheDocument();
    });

    it('defaults to the placeholder option when no value is given', () => {
      const {getByLabelText} = render(Select, baseProps);
      expect(getByLabelText('Chauffeur')).toHaveValue('');
    });

    it('pre-selects the option matching the given value', () => {
      const {getByLabelText} = render(Select, {...baseProps, value: 2});
      expect(getByLabelText('Chauffeur')).toHaveValue('2');
    });
  });

  describe('without error', () => {
    it('shows no error message when error is undefined', () => {
      const {container} = render(Select, baseProps);
      expect(container.querySelector('p')).not.toBeInTheDocument();
    });

    it('shows no error message when error is null', () => {
      const {container} = render(Select, {...baseProps, error: null});
      expect(container.querySelector('p')).not.toBeInTheDocument();
    });

    it('select has border-border class', () => {
      const {getByLabelText} = render(Select, baseProps);
      expect(getByLabelText('Chauffeur')).toHaveClass('border-border');
    });
  });

  describe('with error as string', () => {
    it('shows the error message', () => {
      const {getByText} = render(Select, {...baseProps, error: 'Chauffeur invalide'});
      expect(getByText('Chauffeur invalide')).toBeInTheDocument();
    });

    it('select has border-dt-red class', () => {
      const {getByLabelText} = render(Select, {...baseProps, error: 'Chauffeur invalide'});
      expect(getByLabelText('Chauffeur')).toHaveClass('border-dt-red');
    });
  });

  describe('with error as array', () => {
    it('shows the first error message', () => {
      const {getByText} = render(Select, {
        ...baseProps,
        error: ['First error', 'Second error'],
      });
      expect(getByText('First error')).toBeInTheDocument();
    });

    it('does not show the second error message', () => {
      const {queryByText} = render(Select, {
        ...baseProps,
        error: ['First error', 'Second error'],
      });
      expect(queryByText('Second error')).not.toBeInTheDocument();
    });
  });
});
