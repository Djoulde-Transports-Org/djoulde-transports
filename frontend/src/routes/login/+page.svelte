<script lang="ts">
  import SignInForm from '$lib/components/session/SignInForm.svelte';
  import logo from '$lib/assets/djoulde-transport-logo.png';
  import heroTruck from '$lib/assets/hero-truck.png';
</script>

<div class="min-h-screen flex items-center justify-center px-4 relative">
  <img src={heroTruck} alt="" class="fixed inset-0 w-screen h-screen object-cover -z-10" />
  <div class="fixed inset-0 bg-black/25 -z-10"></div>
  <div class="w-[26.6rem] max-[320px]:w-[100vw] relative z-10">
    <div
      class="bg-white border !border-[#EAECF0] rounded-t-2xl h-[5.5rem] px-[2.5rem] flex justify-center items-center"
    >
      <img src={logo} alt="Djoulde Transports" class="h-full object-contain" />
    </div>
    <div
      class="flex flex-column gap-[1.5rem] bg-[#FCFCFD] border !border-[#EAECF0] rounded-b-2xl px-[2.5rem] pt-[2.5rem] pb-[3rem]"
    >
      <SignInForm />
    </div>
  </div>
</div>
