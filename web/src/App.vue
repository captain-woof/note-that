<script setup lang="ts">
import { RouterView } from "vue-router";
import Navbar from "./components/organisms/navbar/index.vue";
import Container from "./components/atoms/container.vue";
</script>

<template>
    <Navbar />
    <Container>
        <RouterView />
    </Container>
</template>