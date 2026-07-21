import {render, fireEvent} from '@testing-library/svelte';
import TruckDrawer from '$lib/components/flotte/TruckDrawer.svelte';
import type {Truck} from '$lib/types/truck';
import {makeTruck} from '../../../mocks/truck';

const TRUCK: Truck = makeTruck({
  id: 1,
  plate_number: 'GN-3310-C',
  make: 'Volvo',
  model: 'FH',
  year: 2019,
  status: 'on_trip',
  last_oil_change_on: '2025-06-12',
  driver: {
    id: 7,
    first_name: 'Ibrahima',
    last_name: 'Sow',
    full_name: 'Ibrahima Sow',
    phone_number: '+224 600 00 00 00',
    role: 'driver',
    user_id: null,
  },
  tank: {
    id: 1,
    truck_id: 1,
    plate_number: 'TC-041',
    vin: null,
    make: null,
    model: null,
    year: null,
    capacity: 33_000,
    status: 'active',
    conformity_certificate_expires_on: null,
    conformity_certificate_days_remaining: 25,
  },
  truck_insurance_days_remaining: 45,
  cargo_insurance_days_remaining: 120,
  technical_inspection_days_remaining: 8,
  operating_permit_days_remaining: -5,
  truck_registration_days_remaining: 330,
  trips_count: 12,
  total_km: 4_500,
  total_liters_delivered: 96_000,
});

describe('TruckDrawer', () => {
  it('renders nothing when truck is null', () => {
    const {container} = render(TruckDrawer, {truck: null, onClose: vi.fn()});
    expect(container.querySelector('[role="dialog"]')).not.toBeInTheDocument();
  });

  it('renders the plate number, model and status badge', () => {
    const {getByText} = render(TruckDrawer, {truck: TRUCK, onClose: vi.fn()});
    expect(getByText('GN-3310-C')).toBeInTheDocument();
    expect(getByText('Volvo FH · 2019')).toBeInTheDocument();
    expect(getByText('En route')).toBeInTheDocument();
  });

  it('renders the tank summary and last oil change date', () => {
    const {getByText} = render(TruckDrawer, {truck: TRUCK, onClose: vi.fn()});
    expect(getByText('TC-041 · 33 000 L')).toBeInTheDocument();
    expect(getByText('12/06/2025')).toBeInTheDocument();
  });

  describe('driver card', () => {
    it('shows the driver name, id and phone when assigned', () => {
      const {getByText} = render(TruckDrawer, {truck: TRUCK, onClose: vi.fn()});
      expect(getByText('Ibrahima Sow')).toBeInTheDocument();
      expect(getByText('ID 7')).toBeInTheDocument();
      expect(getByText('+224 600 00 00 00')).toBeInTheDocument();
    });

    it('shows the driver initials as an avatar', () => {
      const {getByText} = render(TruckDrawer, {truck: TRUCK, onClose: vi.fn()});
      expect(getByText('IS')).toBeInTheDocument();
    });

    it('shows an empty state when no driver is assigned', () => {
      const {getByText} = render(TruckDrawer, {
        truck: makeTruck({...TRUCK, driver: null}),
        onClose: vi.fn(),
      });
      expect(getByText('Aucun chauffeur assigné.')).toBeInTheDocument();
    });
  });

  describe('documents', () => {
    it('renders all 6 document rows with their labels', () => {
      const {getByText} = render(TruckDrawer, {truck: TRUCK, onClose: vi.fn()});
      expect(getByText('Ass. camion')).toBeInTheDocument();
      expect(getByText('Ass. produit')).toBeInTheDocument();
      expect(getByText('Visite tech.')).toBeInTheDocument();
      expect(getByText('Carte de Transport')).toBeInTheDocument();
      expect(getByText('Carte grise')).toBeInTheDocument();
      expect(getByText('Baremage')).toBeInTheDocument();
    });

    it('renders the expiry pill for each document', () => {
      const {getByText} = render(TruckDrawer, {truck: TRUCK, onClose: vi.fn()});
      expect(getByText('dans 45j')).toHaveClass('text-dt-yellow');
      expect(getByText('dans 120j')).toHaveClass('text-dt-green');
      expect(getByText('dans 8j')).toHaveClass('text-dt-red');
      expect(getByText('Expiré')).toHaveClass('text-dt-red');
      expect(getByText('dans 330j')).toHaveClass('text-dt-green');
      expect(getByText('dans 25j')).toHaveClass('text-dt-yellow');
    });
  });

  describe('stats', () => {
    it('renders trips, km and liters delivered', () => {
      const {getByText} = render(TruckDrawer, {truck: TRUCK, onClose: vi.fn()});
      expect(getByText('12')).toBeInTheDocument();
      expect(getByText('4 500')).toBeInTheDocument();
      expect(getByText('96 000')).toBeInTheDocument();
      expect(getByText('Trajets effectués')).toBeInTheDocument();
      expect(getByText('Km parcourus')).toBeInTheDocument();
      expect(getByText('Litres livrés')).toBeInTheDocument();
    });
  });

  describe('closing', () => {
    it('calls onClose when the overlay is clicked', async () => {
      const onClose = vi.fn();
      const {container} = render(TruckDrawer, {truck: TRUCK, onClose});
      await fireEvent.click(container.querySelector('[role="presentation"]') as HTMLElement);
      expect(onClose).toHaveBeenCalledOnce();
    });

    it('calls onClose when the close button is clicked', async () => {
      const onClose = vi.fn();
      const {getByLabelText} = render(TruckDrawer, {truck: TRUCK, onClose});
      await fireEvent.click(getByLabelText('Fermer'));
      expect(onClose).toHaveBeenCalledOnce();
    });

    it('calls onClose when the footer Fermer button is clicked', async () => {
      const onClose = vi.fn();
      const {getByText} = render(TruckDrawer, {truck: TRUCK, onClose});
      await fireEvent.click(getByText('Fermer'));
      expect(onClose).toHaveBeenCalledOnce();
    });

    it('calls onClose when Escape is pressed while open', async () => {
      const onClose = vi.fn();
      render(TruckDrawer, {truck: TRUCK, onClose});
      await fireEvent.keyDown(window, {key: 'Escape'});
      expect(onClose).toHaveBeenCalledOnce();
    });

    it('does not call onClose on Escape when the drawer is already closed', async () => {
      const onClose = vi.fn();
      render(TruckDrawer, {truck: null, onClose});
      await fireEvent.keyDown(window, {key: 'Escape'});
      expect(onClose).not.toHaveBeenCalled();
    });
  });
});
