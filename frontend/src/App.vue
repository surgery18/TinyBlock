<template>
	<div id="app">
		<router-view />
	</div>
</template>

<script>
	export default {
		name: "App",
	}
</script>

<style>
	* {
		margin: 0;
		padding: 0;
		box-sizing: border-box;
	}

	body,
	html {
		height: auto;
		min-height: 100%;
	}

	body {
		font-family: "Arial", sans-serif;
		background: linear-gradient(120deg, #84fab0, #8a2387);
		background-repeat: no-repeat;
		background-attachment: fixed;
		background-size: cover;
		color: #ffffff;
	}

	.table {
		border-radius: 15px;
		overflow: hidden;
	}

	table thead tr {
		background-color: #f8f9fa;
	}

	.glass-container {
		background: rgba(
			255,
			255,
			255,
			0.1
		); /* Semi-transparent white background */
		backdrop-filter: blur(10px); /* Creates the frosted glass effect */
		border-radius: 15px; /* Optional: round the corners a bit for aesthetics */
		padding: 40px; /* Increased internal space around the content */
		box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Slight shadow for depth */
		margin: 20px; /* Space around the container */
		max-width: 1000px; /* Optional: limit the width for better readability */
		margin-left: auto; /* Center the container */
		margin-right: auto;
	}
</style>
