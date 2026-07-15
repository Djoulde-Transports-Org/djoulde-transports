import {render} from '@testing-library/svelte';
import StatsCard from '$lib/components/dashboard/StatsCard.svelte';

const BASE = {
  label: 'Camions actifs',
  value: '7',
  sub: '4 en route · 2 prêts · 1 maintenance',
  icon: 'truck' as const,
};

describe('StatsCard', () => {
  describe('loaded state', () => {
    it('renders the label', () => {
      const {getByText} = render(StatsCard, BASE);
      expect(getByText('Camions actifs')).toBeInTheDocument();
    });

    it('renders the value', () => {
      const {getByText} = render(StatsCard, BASE);
      expect(getByText('7')).toBeInTheDocument();
    });

    it('renders the sub-text', () => {
      const {getByText} = render(StatsCard, BASE);
      expect(getByText('4 en route · 2 prêts · 1 maintenance')).toBeInTheDocument();
    });

    it('does not show the skeleton', () => {
      const {container} = render(StatsCard, BASE);
      expect(container.querySelector('.animate-pulse')).not.toBeInTheDocument();
    });
  });

  describe('loading state', () => {
    it('shows skeleton elements', () => {
      const {container} = render(StatsCard, {...BASE, loading: true});
      expect(container.querySelectorAll('.animate-pulse').length).toBeGreaterThan(0);
    });

    it('does not render the value', () => {
      const {queryByText} = render(StatsCard, {...BASE, loading: true});
      expect(queryByText('7')).not.toBeInTheDocument();
    });

    it('does not render the sub-text', () => {
      const {queryByText} = render(StatsCard, {...BASE, loading: true});
      expect(queryByText('4 en route · 2 prêts · 1 maintenance')).not.toBeInTheDocument();
    });

    it('still renders the label while loading', () => {
      const {getByText} = render(StatsCard, {...BASE, loading: true});
      expect(getByText('Camions actifs')).toBeInTheDocument();
    });
  });

  describe('defaults', () => {
    it('renders without value or sub when not provided', () => {
      const {container} = render(StatsCard, {label: 'Test', icon: 'truck' as const});
      expect(container.querySelector('.animate-pulse')).not.toBeInTheDocument();
    });
  });
});
