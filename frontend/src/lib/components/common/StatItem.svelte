<script lang="ts">
  let {
    label,
    value,
    emphasize = false,
  }: {
    label: string;
    value: string;
    emphasize?: boolean;
  } = $props();
</script>

<div>
  <div class="text-[10px] text-dt-text-muted uppercase tracking-wide">{label}</div>
  <div class="text-dt-text {emphasize ? 'font-bold' : 'font-medium'}">{value}</div>
</div>
