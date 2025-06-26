<template>
  <div class="form-field">
    <label>{{ label }}</label>
    <slot></slot>
  </div>
</template>

<script lang="ts" setup>
  defineProps<{
    label: string
  }>()
</script>

<style scoped>
  .form-field {
    @apply mb-4;
  }
</style>
