<script lang="ts" setup>
import { reactive } from "vue";
import { RouterLink } from "vue-router";

const pages = reactive([
    {
        name: "Home",
        route: "/"
    },
    {
        name: "Privacy Policy",
        route: "/privacy-policy"
    }
]);
</script>

<template>
    <nav class="navbar">

        <h1 class="navbar__heading">
            NOTE THAT
        </h1>

        <ul class="navbar__pages">
            <li v-for="page in pages" class="navbar__pages__page">
                <!-- Link -->
                <RouterLink :to="page.route">{{page.name}}</RouterLink>

                <!-- Underline animated -->
                <div class="navbar__pages__page__underline" />
            </li>
        </ul>
    </nav>
</template>

<style scoped lang="css">
.navbar {
    width: 100%;
    padding: var(--sp-300);
    position: fixed;
    top: 0;
    left: 0;
    display: flex;
    align-items: center;
    background-color: var(--color-blue);
}

.navbar__heading {
    font-size: var(--fs-600);
    color: var(--color-white);
}

.navbar__pages {
    margin-left: auto;
    display: flex;
    gap: var(--sp-300);
    width: max-content;
    height: 100%;
}

.navbar__pages__page {
    font-weight: 500;
    color: var(--color-white);
    position: relative;
    overflow: hidden;
    font-size: var(--fs-300);
}

.navbar__pages__page__underline {
    position: absolute;
    bottom: 0;
    left: 0;
    height: 2px;
    width: 100%;
    background-color: var(--color-white);
    transform: translateX(-100%);
    transition: all 0.3s ease-out;
}

.navbar__pages__page:hover>.navbar__pages__page__underline {
    transform: translateX(0%);
}

@media (min-width: 480px) {
    .navbar {
        padding: var(--sp-400) var(--sp-500);
    }

    .navbar__pages {
        gap: var(--sp-500);
    }

    .navbar__pages__page {
        font-size: var(--fs-400);
    }
}
</style>