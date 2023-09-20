<template>
	<div class="glass-container">
		<!-- Header -->
		<header class="d-flex align-items-center justify-content-between">
			<div class="d-flex align-items-center">
				<!-- Add flexbox classes here -->
				<img
					src="../assets/logo.png"
					alt="TinyBlock Logo"
					width="50"
					height="50"
				/>
				<h1 class="ms-3">TinyBlock</h1>
			</div>
		</header>

		<h2>Redirecting from short code to URL</h2>
	</div>
</template>

<script>
	import Web3 from "web3"
	import TinyBlockContract from "../../../build/contracts/TinyBlock.json"
	import Chain from "@/configs/Chain"

	export default {
		name: "Redirect",
		async created() {
			//init web3 with a reader
			//if slow then convert to using quicknode
			const keys = Object.keys(TinyBlockContract.networks)
			const lastKey = keys[keys.length - 1]
			const nid = Chain.local ? +lastKey : Chain.mainnet ? 56 : 97
			const web3 = new Web3(Chain.getRpcUrl())
			//load up the contract
			const contract = new web3.eth.Contract(
				TinyBlockContract.abi,
				TinyBlockContract.networks[nid].address
			)
			//call method
			try {
				const response = await contract.methods
					.getUrlFromCode(this.$route.params.match[0])
					.call()
				if (response.url && response.code === this.$route.params.match[0]) {
					window.location.href = response.url
				} else {
					alert("Short code does not exist")
					return this.$router.push({ path: "/" })
				}
			} catch (e) {
				console.log(e)
				//give alert and then homepage
				alert(e.message)
				return this.$router.push({ path: "/" })
			}
		},
	}
</script>
