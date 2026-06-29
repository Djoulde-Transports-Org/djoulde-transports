---
name: project-stack
description: Tech stack and architecture for Djoulde Transports — Rails API + SvelteKit frontend
metadata:
  type: project
---

Rails 8.1 + SvelteKit 5 (Svelte 5 runes) monorepo. SSR disabled (`ssr = false`). Tailwind CSS v4 + Flowbite. TanStack Query for server state. Felte + Yup for forms. Vitest + Testing Library for tests.

Backend: Grape 3.3 API mounted at `/api/v1`, Doorkeeper OAuth2, Pundit policies, Discard soft deletes, Audited trail, Kaminari pagination.

Frontend lives at `frontend/`. API proxied via Vite dev server. Auth via Bearer token stored in localStorage (`djoulde_session`).

**Why:** Separate frontend/backend teams with clean API boundary.
**How to apply:** All UI work happens under `frontend/src/`. API endpoints follow Grape resource-module pattern (one action per file under `app/api/v1/endpoints/`).
