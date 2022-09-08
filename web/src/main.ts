import { createApp } from 'vue';
import './styles/index.css';
import App from './App.vue';
import { router } from "./routes/index";

// Create and init app
const app = createApp(App);
app.use(router);

// Mount app
app.mount('#app')
