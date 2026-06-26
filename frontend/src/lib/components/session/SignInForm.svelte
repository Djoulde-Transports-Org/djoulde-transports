<script lang="ts">
  import {loginValidationSchema} from '$lib/store/session/login';
  import {login} from '$lib/api/sessions';
  import {authStore} from '$lib/store/session/auth';

  import Header from '$lib/components/session/Header.svelte';
  import Input from '$lib/components/common/Input.svelte';
  import PasswordInput from '$lib/components/common/PasswordInput.svelte';
  import Button from '$lib/components/common/Button.svelte';
  import Form from '$lib/components/common/Form.svelte';

  type SignInValues = {
    email: string;
    password: string;
  };

  let errorMessage = $state<string | null>(null);

  const handleSubmit = async (values: SignInValues): Promise<void> => {
    errorMessage = null;
    try {
      const session = await login(values.email, values.password);
      authStore.setSession(session);
      window.location.href = session.roles.includes('super_admin') ? '/admin' : '/';
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Sign in failed. Please try again.';
    }
  };
</script>

<div class="w-full flex flex-col gap-[1.5rem]">
  <Header text="Sign in to your account" />
  <Form
    id="sign-in"
    schema={loginValidationSchema}
    onSubmit={handleSubmit}
    class="w-full flex flex-col gap-[1.5rem]"
  >
    {#snippet children({errors, isValid, isSubmitting})}
      <Input
        id="email"
        name="email"
        type="email"
        label="Email"
        placeholder="Enter your email"
        autocomplete="email"
        error={errors.email}
      />

      <PasswordInput
        id="password"
        name="password"
        label="Password"
        placeholder="Enter your password"
        autocomplete="current-password"
        error={errors.password}
      />

      {#if errorMessage}
        <p class="text-sm text-red-600">{errorMessage}</p>
      {/if}

      <Button type="submit" disabled={!isValid || isSubmitting}>
        {isSubmitting ? 'Signing in...' : 'Sign in'}
      </Button>

      <Button type="button" variant="ghost">Forgot password?</Button>
    {/snippet}
  </Form>
</div>
