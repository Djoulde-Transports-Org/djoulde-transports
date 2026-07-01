<script module lang="ts">
  import {
    LayoutDashboard,
    Truck,
    Users,
    Navigation,
    Wrench,
    Receipt,
    FolderOpen,
    ChevronRight,
    ChevronLeft,
    ChevronDown,
    ChevronUp,
    Plus,
    X,
    Check,
    AlertTriangle,
    Info,
    Search,
    Filter,
    Download,
    Upload,
    Edit,
    Trash2,
    Eye,
    EyeOff,
    RefreshCw,
    Clock,
    Calendar,
    MapPin,
    Phone,
    Mail,
    User,
    Settings,
    LogOut,
  } from 'lucide-svelte';

  export const icons = {
    dashboard: LayoutDashboard,
    truck: Truck,
    users: Users,
    navigation: Navigation,
    wrench: Wrench,
    receipt: Receipt,
    folder: FolderOpen,
    'chevron-right': ChevronRight,
    'chevron-left': ChevronLeft,
    'chevron-down': ChevronDown,
    'chevron-up': ChevronUp,
    plus: Plus,
    x: X,
    check: Check,
    'alert-triangle': AlertTriangle,
    info: Info,
    search: Search,
    filter: Filter,
    download: Download,
    upload: Upload,
    edit: Edit,
    trash: Trash2,
    eye: Eye,
    'eye-off': EyeOff,
    refresh: RefreshCw,
    clock: Clock,
    calendar: Calendar,
    'map-pin': MapPin,
    phone: Phone,
    mail: Mail,
    user: User,
    settings: Settings,
    logout: LogOut,
  } as const;

  export type IconName = keyof typeof icons;
</script>

<script lang="ts">
  let {
    name,
    size = 16,
    class: className = '',
    strokeWidth = 1.75,
  }: {
    name: IconName;
    size?: number;
    class?: string;
    strokeWidth?: number;
  } = $props();

  const Component = $derived(icons[name]);
</script>

<Component {size} {strokeWidth} class={className} />
