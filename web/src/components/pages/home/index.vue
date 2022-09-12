<script lang="ts" setup>
import { onMounted, onUnmounted, ref } from 'vue';

// Video source state
let videoSource = ref("");

// Function to change video source
function setVideoSource() {
    videoSource.value = window.matchMedia("(min-width: 576px)").matches
        ? "/videos/note-that-demo-widescreen.m4v"
        : "/videos/note-that-demo.m4v";
}

// Mounted lifecycle
onMounted(() => {
    // For video source
    setVideoSource();
    window.addEventListener("resize", setVideoSource);
});

// Unmounted lifecycle
onUnmounted(() => {
    // Remove resize listener for video source
    window.removeEventListener("resize", setVideoSource);
})
</script>

<template>

    <header class="header">
        <h1 class="header__title">NOTE THAT</h1>
        <h2 class="header__subtitle">A note-taking application that makes it simple to take rich notes</h2>
    </header>

    <main class="main">

        <!-- Demo screen -->
        <img src="/images/screen.png" alt="note that screen" class="main__demo-screen" />

        <!-- TODO: DOWNLOAD -->

        <!-- Demo video -->
        <h1 class="main__demo-heading">Why choose Note That?</h1>
        <video controls class="main__demo-video" :src="videoSource" />
    </main>
</template>

<style lang="css" scoped>
.header__title {
    margin: var(--sp-700) auto 0 auto;
    text-align: center;
}

.header__subtitle {
    font-size: var(--fs-700);
    margin: var(--sp-200) auto 0 auto;
    text-align: center;
}

.main__demo-screen {
    margin: 0 auto;
    width: 80%;
}

.main__demo-heading {
    font-size: var(--fs-600);
    margin: var(--sp-200) auto 0 auto;
    text-align: center;
}

.main__demo-video {
    margin: var(--sp-300) auto 0 auto;
    width: 80%;
}

@media (min-width: 576px) {
    .main__demo-screen {
        margin: 0 auto;
        width: 50%;
    }

    .main__demo-heading {
        font-size: var(--fs-700);
    }
}
</style>