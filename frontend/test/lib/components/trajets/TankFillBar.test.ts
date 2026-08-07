import {render} from '@testing-library/svelte';
import TankFillBar from '$lib/components/trajets/TankFillBar.svelte';

describe('TankFillBar', () => {
  describe('without a selected truck', () => {
    it('renders nothing when capacity is null', () => {
      const {queryByTestId} = render(TankFillBar, {
        capacity: null,
        dieselQuantity: 0,
        gasolineQuantity: 0,
      });
      expect(queryByTestId('tank-fill-bar')).not.toBeInTheDocument();
    });
  });

  describe('empty state', () => {
    it('shows the empty prompt when no quantities are entered', () => {
      const {getByText, getByTestId} = render(TankFillBar, {
        capacity: 1500,
        dieselQuantity: 0,
        gasolineQuantity: 0,
      });
      expect(getByTestId('tank-fill-bar')).toBeInTheDocument();
      expect(
        getByText('Renseignez les quantités pour visualiser le remplissage')
      ).toBeInTheDocument();
      expect(getByText('1 500 L')).toBeInTheDocument();
    });
  });

  describe('partial state', () => {
    it('shows how many liters remain', () => {
      const {getByText} = render(TankFillBar, {
        capacity: 1500,
        dieselQuantity: 800,
        gasolineQuantity: 200,
      });
      expect(getByText('500 L restants')).toBeInTheDocument();
    });

    it('sizes each fuel segment proportionally to capacity', () => {
      const {container} = render(TankFillBar, {
        capacity: 1000,
        dieselQuantity: 600,
        gasolineQuantity: 100,
      });
      const [dieselSegment, gasolineSegment] = container.querySelectorAll<HTMLDivElement>(
        '.bg-accent.h-full, .bg-brand-blue.h-full'
      );
      expect(dieselSegment.style.width).toBe('60%');
      expect(gasolineSegment.style.width).toBe('10%');
    });
  });

  describe('exact state', () => {
    it('shows the exact fill confirmation', () => {
      const {getByText} = render(TankFillBar, {
        capacity: 1500,
        dieselQuantity: 1000,
        gasolineQuantity: 500,
      });
      expect(getByText('Citerne remplie exactement')).toBeInTheDocument();
    });
  });

  describe('over-capacity state', () => {
    it('shows the overage in liters', () => {
      const {getByText} = render(TankFillBar, {
        capacity: 1500,
        dieselQuantity: 1000,
        gasolineQuantity: 600,
      });
      expect(getByText('Dépassement de 100 L')).toBeInTheDocument();
    });

    it('scales the fuel segments to fill the bar based on their share of the total', () => {
      const {container} = render(TankFillBar, {
        capacity: 1000,
        dieselQuantity: 900,
        gasolineQuantity: 300,
      });
      const [dieselSegment, gasolineSegment] = container.querySelectorAll<HTMLDivElement>(
        '.bg-accent.h-full, .bg-brand-blue.h-full'
      );
      expect(dieselSegment.style.width).toBe('75%');
      expect(gasolineSegment.style.width).toBe('25%');
    });
  });
});
