<template>
	<div v-if="message" class="toast" :class="type">
		{{ message }}
	</div>
</template>

<script>
	export default {
		data() {
			return {
				message: "",
				type: "success", // can be 'success' or 'error'
			}
		},
		methods: {
			show(message, type = "success") {
				this.message = message
				this.type = type
				setTimeout(() => {
					this.message = ""
				}, 5000)
			},
		},
	}
</script>

<style scoped>
	.toast:not(.show) {
		display: block;
	}
	.toast {
		position: sticky;
		bottom: 20px;
		left: 50%;
		transform: translateX(-50%);
		background-color: rgba(0, 0, 0, 0.7);
		color: white;
		padding: 10px 20px;
		border-radius: 5px;
		box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
		transition: bottom 0.5s ease;
		z-index: 9999; /* Ensure the toast is above other elements */
	}

	.toast.success {
		background-color: rgba(46, 204, 113, 0.9); /* Green for success */
	}

	.toast.error {
		background-color: rgba(231, 76, 60, 0.9); /* Red for error */
	}
</style>
