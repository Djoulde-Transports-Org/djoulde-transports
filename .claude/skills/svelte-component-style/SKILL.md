---
name: svelte-component-style
description: Use when writing or editing any Svelte component under frontend/src/. Enforces Tailwind-first styling, arrow functions, post-edit quality checks, and test coverage.
---

# Svelte component conventions

## Rule: Tailwind first, no `<style>` blocks

Style every element with Tailwind utility classes. Do **not** add a `<style>` block unless the effect is genuinely impossible in Tailwind (e.g. `clip-path` polygons, `@keyframes` animations). When a `<style>` block is unavoidable, keep it to the minimum — a single selector at most.

## Rule: Arrow functions only

Always use arrow functions. Never use `function` declarations or `function` expressions inside components.

```svelte
<!-- Good -->
<script lang="ts">
  const handleClick = () => { ... };
  const isActive = (href: string) => activePath === href;
</script>

<!-- Bad -->
<script lang="ts">
  function handleClick() { ... }
</script>
```

This applies to event handlers, helpers, reactive declarations, and module-level utilities alike.

## Rule: Run quality checks after every change

After writing or editing any component, type file, store, or test, run all three checks in this order:

```bash
cd frontend
npm run lint          # ESLint
npm run check         # svelte-check + TypeScript
npm run format:check  # Prettier
```

Fix every error before reporting the task as done. If `format:check` fails, run `npm run format` to auto-fix, then re-run the check.

## Rule: Add tests for every new component or behavior

When adding a new component or meaningful behavior to an existing one:

1. Write a test file at `frontend/test/lib/...` mirroring the source path.
2. Cover every prop variant, every conditional branch, and every interactive behavior.
3. After writing tests, run `npm run test` and fix any failures.

Test gaps to always cover:

- Every prop that changes rendered output (including edge cases: `null`, empty string `''`, empty array `[]`)
- Every event handler / interaction (click, hover, form submit)
- Every conditional block (`{#if}`) — both branches
- Active/inactive state for navigation
- Authenticated vs unauthenticated states
- Error states and success states

## Design tokens

Tokens are derived from the Djoulde Transport logo: navy blue (`#1b4080`) and orange-flame (`#e8621e`). Defined in `frontend/src/app.css` as a `@theme` block — Tailwind v4 generates utilities directly from `--color-*` variables.

| Token | CSS variable | Hex | Usage |
|---|---|---|---|
| `ground` | `--color-ground` | `#08101e` | Page / sidebar background |
| `surface` | `--color-surface` | `#0e1a2e` | Card / input backgrounds |
| `surface-2` | `--color-surface-2` | `#162540` | Elevated surface |
| `border` | `--color-border` | `#1d3050` | Default border |
| `border-soft` | `--color-border-soft` | `#162038` | Subtle divider |
| `dt-text` | `--color-dt-text` | `#e8ecf4` | Primary text |
| `dt-text-mid` | `--color-dt-text-mid` | `#8a9dc0` | Secondary text |
| `dt-text-muted` | `--color-dt-text-muted` | `#526080` | Disabled / placeholder text |
| `accent` | `--color-accent` | `#e8621e` | Orange accent (logo flame) |
| `accent-dim` | `--color-accent-dim` | `rgba(232, 98, 30, 0.12)` | Accent tint backgrounds |
| `brand-blue` | `--color-brand-blue` | `#1b4080` | Logo blue (lettermark) |
| `dt-green` | `--color-dt-green` | `#2e7a52` | Success |
| `dt-yellow` | `--color-dt-yellow` | `#c09820` | Warning |
| `dt-red` | `--color-dt-red` | `#c03018` | Error / danger |

Use them as Tailwind utilities: `bg-ground`, `text-accent`, `border-border`, `text-dt-text`, etc.

When adding a new semantic color, add it to `frontend/src/app.css` under `@theme` first, then document it in this table.

## Examples

### Preferred — pure Tailwind
```svelte
<button class="flex items-center gap-2 px-4 py-2 rounded bg-surface border border-border text-dt-text text-sm font-medium hover:bg-surface-2 transition-colors duration-[130ms]">
  Click me
</button>
```

### Accepted — Tailwind + minimal style block for an impossible property
```svelte
<div
  class="w-8 h-8 flex items-center justify-center bg-accent text-ground text-[9px] font-black"
  style="clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%)"
>
  DT
</div>
```

### Not allowed — plain CSS in style block for things Tailwind can do
```svelte
<!-- BAD -->
<style>
  .nav { display: flex; gap: 8px; }
</style>
```

## Conditional classes

```svelte
class="px-4 py-2 {isActive ? 'text-dt-text bg-surface' : 'text-dt-text-muted hover:text-dt-text'}"
```

## Arbitrary values

```svelte
class="w-[224px] text-[13px] py-[9px] duration-[130ms]"
```

## When to reach for `<style>`

Only when the CSS property has no Tailwind equivalent and cannot be expressed via an inline `style` attribute (e.g. pseudo-element content, `@keyframes` referenced by name). Even then, scope as tightly as possible.
