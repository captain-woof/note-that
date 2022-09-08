<template>
    <div class="container">
        <slot></slot>
    </div>
</template>

<style scoped lang="css">
.container {
    width: 100%;
    max-width: 900px;
    margin: 0 auto;
    padding: var(--sp-400);
}
</style>