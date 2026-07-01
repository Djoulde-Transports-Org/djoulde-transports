import {render} from '@testing-library/svelte';
import {vi, beforeEach, afterEach, describe, it, expect} from 'vitest';
import {tick} from 'svelte';
import Topbar from '$lib/components/layout/Topbar.svelte';

describe('Topbar', () => {
  describe('title', () => {
    it('renders the title prop', () => {
      const {getByRole} = render(Topbar, {props: {title: 'Flotte'}});
      expect(getByRole('heading', {level: 1})).toHaveTextContent('Flotte');
    });

    it('renders a different title when changed', () => {
      const {getByRole} = render(Topbar, {props: {title: 'Tableau de bord'}});
      expect(getByRole('heading', {level: 1})).toHaveTextContent('Tableau de bord');
    });
  });

  describe('live indicator', () => {
    it('shows "En direct" text', () => {
      const {getByText} = render(Topbar, {props: {title: 'Test'}});
      expect(getByText('En direct')).toBeInTheDocument();
    });

    it('renders the green indicator dot', () => {
      const {container} = render(Topbar, {props: {title: 'Test'}});
      expect(container.querySelector('.bg-dt-green')).toBeInTheDocument();
    });

    it('renders the pulsing animation dot', () => {
      const {container} = render(Topbar, {props: {title: 'Test'}});
      expect(container.querySelector('.animate-ping')).toBeInTheDocument();
    });
  });

  describe('clock', () => {
    beforeEach(() => {
      vi.useFakeTimers();
      vi.setSystemTime(new Date('2024-01-15T14:30:45'));
    });

    afterEach(() => {
      vi.useRealTimers();
    });

    it('displays the current time on mount', () => {
      const {getByText} = render(Topbar, {props: {title: 'Test'}});
      expect(getByText('14:30:45')).toBeInTheDocument();
    });

    it('updates the clock every second', async () => {
      const {getByText} = render(Topbar, {props: {title: 'Test'}});
      expect(getByText('14:30:45')).toBeInTheDocument();

      vi.advanceTimersByTime(1000);
      await tick();

      expect(getByText('14:30:46')).toBeInTheDocument();
    });

    it('continues updating after multiple seconds', async () => {
      const {getByText} = render(Topbar, {props: {title: 'Test'}});
      vi.advanceTimersByTime(5000);
      await tick();
      expect(getByText('14:30:50')).toBeInTheDocument();
    });
  });

  describe('actions slot', () => {
    it('renders nothing in the actions area when no snippet is provided', () => {
      const {container} = render(Topbar, {props: {title: 'Test'}});
      expect(container.querySelector('[data-testid="topbar-actions"]')).not.toBeInTheDocument();
    });
  });
});
