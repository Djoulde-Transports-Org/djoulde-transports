import {render} from '@testing-library/svelte';
import BillingPreview from '$lib/components/trajets/BillingPreview.svelte';

describe('BillingPreview', () => {
  describe('when inputs are incomplete', () => {
    it('renders nothing when no route rate is selected', () => {
      const {queryByTestId} = render(BillingPreview, {rate: null, totalLiters: 1000});
      expect(queryByTestId('billing-preview')).not.toBeInTheDocument();
    });

    it('renders nothing when no liters have been entered', () => {
      const {queryByTestId} = render(BillingPreview, {rate: 1500, totalLiters: 0});
      expect(queryByTestId('billing-preview')).not.toBeInTheDocument();
    });
  });

  describe('when inputs are complete', () => {
    it('computes HT as liters times the route rate', () => {
      const {getByText} = render(BillingPreview, {rate: 1500, totalLiters: 1000});
      expect(getByText('1 500 000 GNF')).toBeInTheDocument();
    });

    it('computes TVA at 18% of HT', () => {
      const {getByText} = render(BillingPreview, {rate: 1500, totalLiters: 1000});
      expect(getByText('270 000 GNF')).toBeInTheDocument();
    });

    it('computes the total TTC as HT plus TVA', () => {
      const {getByText} = render(BillingPreview, {rate: 1500, totalLiters: 1000});
      expect(getByText('1 770 000 GNF')).toBeInTheDocument();
    });

    it('updates reactively when the rate or liters change', async () => {
      const {getByText, rerender} = render(BillingPreview, {rate: 1500, totalLiters: 1000});
      expect(getByText('1 770 000 GNF')).toBeInTheDocument();

      await rerender({rate: 1800, totalLiters: 500});
      expect(getByText('900 000 GNF')).toBeInTheDocument();
      expect(getByText('162 000 GNF')).toBeInTheDocument();
      expect(getByText('1 062 000 GNF')).toBeInTheDocument();
    });
  });
});
