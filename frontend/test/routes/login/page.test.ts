import {render} from '@testing-library/svelte';
import Page from '$routes/login/+page.svelte';

describe('login/+page', () => {
  describe('logo', () => {
    it('renders the logo image', () => {
      const {getByAltText} = render(Page);
      expect(getByAltText('Djoulde Transports')).toBeInTheDocument();
    });

    it('logo is an img element', () => {
      const {getByAltText} = render(Page);
      expect(getByAltText('Djoulde Transports').tagName).toBe('IMG');
    });
  });

  describe('background', () => {
    it('renders the hero background image', () => {
      const {container} = render(Page);
      const imgs = container.querySelectorAll('img');
      const bg = Array.from(imgs).find((img) => img.alt === '');
      expect(bg).toBeInTheDocument();
    });

    it('renders the dark overlay', () => {
      const {container} = render(Page);
      expect(container.querySelector('.bg-black\\/25')).toBeInTheDocument();
    });
  });

  describe('sign-in form', () => {
    it('renders the email input', () => {
      const {getByLabelText} = render(Page);
      expect(getByLabelText('Email')).toBeInTheDocument();
    });

    it('renders the password input', () => {
      const {getByLabelText} = render(Page);
      expect(getByLabelText('Password')).toBeInTheDocument();
    });

    it('renders the sign in button', () => {
      const {getByRole} = render(Page);
      expect(getByRole('button', {name: 'Sign in'})).toBeInTheDocument();
    });

    it('renders the "Sign in to your account" header', () => {
      const {getByTestId} = render(Page);
      expect(getByTestId('welcome-message')).toHaveTextContent('Sign in to your account');
    });
  });
});
