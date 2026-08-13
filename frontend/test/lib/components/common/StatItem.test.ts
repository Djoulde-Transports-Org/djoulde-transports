import {render} from '@testing-library/svelte';
import StatItem from '$lib/components/common/StatItem.svelte';

describe('StatItem', () => {
  it('renders the label and value', () => {
    const {getByText} = render(StatItem, {label: 'HT', value: '5 000 000 GNF'});
    expect(getByText('HT')).toBeInTheDocument();
    expect(getByText('5 000 000 GNF')).toBeInTheDocument();
  });

  it('renders the value with medium weight by default', () => {
    const {getByText} = render(StatItem, {label: 'HT', value: '5 000 000 GNF'});
    expect(getByText('5 000 000 GNF')).toHaveClass('font-medium');
    expect(getByText('5 000 000 GNF')).not.toHaveClass('font-bold');
  });

  it('renders the value with bold weight when emphasize is true', () => {
    const {getByText} = render(StatItem, {
      label: 'TTC',
      value: '5 900 000 GNF',
      emphasize: true,
    });
    expect(getByText('5 900 000 GNF')).toHaveClass('font-bold');
    expect(getByText('5 900 000 GNF')).not.toHaveClass('font-medium');
  });
});
