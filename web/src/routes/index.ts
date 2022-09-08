import { createRouter, createWebHistory } from "vue-router";
import HomePage from "../components/pages/home/index.vue";
import PrivacyPolicyPage from "../components/pages/privacy-policy/index.vue";

export const router = createRouter({
    history: createWebHistory(),
    routes: [
        {
            path: "/",
            name: "home",
            component: HomePage
        },
        {
            path: "/privacy-policy",
            name: "privacy-policy",
            component: PrivacyPolicyPage
        }
    ]
});