export default {
	local: false,
	mainnet: false,
	getChainId() {
		return this.local ? 1337 : this.mainnet ? 56 : 97
	},
	getRpcUrl() {
		return this.local
			? "http://localhost:8545"
			: this.mainnet
			? "https://bsc-dataseed.binance.org/"
			: "https://data-seed-prebsc-1-s1.binance.org:8545"
	},
}
