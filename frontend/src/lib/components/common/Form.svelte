<script lang="ts" generics="T extends Record<string, unknown>">
  import type {Snippet} from 'svelte';
  import type {AnyObjectSchema, ValidationError} from 'yup';

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
    children: Snippet<[{errors: Record<string, string>; isValid: boolean; isSubmitting: boolean}]>;
  } = $props();

  let errors = $state<Record<string, string>>({});
  let isValid = $state(true);
  let isSubmitting = $state(false);

  const toValues = (form: HTMLFormElement): Record<string, unknown> => {
    const values = Object.fromEntries(new FormData(form).entries());
    // FormData(form) does not reliably read <input type="file"> across environments — read files directly.
    for (const input of form.querySelectorAll('input[type="file"]')) {
      const fileInput = input as HTMLInputElement;
      if (fileInput.name) values[fileInput.name] = fileInput.files?.[0] ?? new File([], '');
    }
    return values;
  };

  const validate = async (form: HTMLFormElement): Promise<boolean> => {
    try {
      await schema.validate(toValues(form), {abortEarly: false});
      errors = {};
      isValid = true;
      return true;
    } catch (err) {
      const next: Record<string, string> = {};
      const yupErr = err as ValidationError;
      for (const e of yupErr.inner ?? []) next[e.path ?? ''] = e.message;
      if (yupErr.path && !yupErr.inner?.length) next[yupErr.path] = yupErr.message;
      errors = next;
      isValid = false;
      return false;
    }
  };

  const oninput = (event: Event) => {
    validate(event.currentTarget as HTMLFormElement);
  };

  const onsubmit = async (event: SubmitEvent) => {
    event.preventDefault();
    const form = event.currentTarget as HTMLFormElement;
    const valid = await validate(form);
    if (!valid) return;
    isSubmitting = true;
    try {
      await onSubmit(toValues(form) as T);
    } finally {
      isSubmitting = false;
    }
  };
</script>

<form {id} data-testid={id ? `form-${id}` : undefined} class={className} {oninput} {onsubmit}>
  {@render children({errors, isValid, isSubmitting})}
</form>
