<script lang="ts" generics="T extends Record<string, unknown>">
  import {untrack} from 'svelte';
  import {createForm} from 'felte';
  import {validator} from '@felte/validator-yup';

  import type {Snippet} from 'svelte';
  import type {AnyObjectSchema} from 'yup';
  import type {Errors} from '@felte/common';

  let {
    id,
    schema,
    onSubmit,
    class: className,
    children,
  }: {
    id?: string;
    schema: AnyObjectSchema;
    onSubmit: (values: T) => Promise<void>;
    class?: string;
    children: Snippet<[{errors: Errors<T>; isValid: boolean; isSubmitting: boolean}]>;
  } = $props();

  const {form, errors, isValid, isSubmitting} = untrack(() =>
    createForm<T>({
      extend: validator({schema}),
      onSubmit,
    }),
  );
</script>

<form use:form {id} data-testid={id ? `form-${id}` : undefined} class={className}>
  {@render children({errors: $errors, isValid: $isValid, isSubmitting: $isSubmitting})}
</form>
