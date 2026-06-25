<script lang="ts">
  import {loginValidationSchema} from '$lib/store/session/login';

  import Header from '$lib/components/session/Header.svelte';
  import Input from '$lib/components/common/Input.svelte';
  import PasswordInput from '$lib/components/common/PasswordInput.svelte';
  import Button from '$lib/components/common/Button.svelte';
  import Form from '$lib/components/common/Form.svelte';

  type SignInValues = {
    email: string;
    password: string;
  };

  const handleSubmit = async (values: SignInValues): Promise<void> => {
    console.log(values);
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
    {#snippet children({isValid, isSubmitting})}
      <Input
        id="email"
        name="email"
        type="email"
        label="Email"
        placeholder="Enter your email"
        autocomplete="email"
      />

      <PasswordInput
        id="password"
        name="password"
        label="Password"
        placeholder="Enter your password"
        autocomplete="current-password"
      />

      <Button type="submit" disabled={!isValid || isSubmitting}>
        {isSubmitting ? 'Signing in...' : 'Sign in'}
      </Button>

      <Button type="button" variant="ghost">Forgot password?</Button>
    {/snippet}
  </Form>
</div>
