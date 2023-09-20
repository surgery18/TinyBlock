import "./assets/main.css"

import { createApp } from "vue"
import { createRouter, createWebHistory } from "vue-router"
import App from "./App.vue"
import TinyBlock from "@/components/TinyBlock.vue"
import Redirect from "@/components/Redirect.vue"

import "bootstrap/dist/css/bootstrap.min.css"
import "bootstrap/dist/js/bootstrap.bundle.min.js" // Contains Popper.js
import "bootstrap-icons/font/bootstrap-icons.css"

const router = createRouter({
	history: createWebHistory(import.meta.env.BASE_URL),
	routes: [
		{
			path: "/",
			component: TinyBlock,
		},
		{
			path: "/:match(.*)*",
			component: Redirect,
		},
	],
})

const app = createApp(App)
app.use(router)
app.mount("#app")
