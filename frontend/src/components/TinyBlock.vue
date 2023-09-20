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
			<div v-if="walletConnected" class="d-flex align-items-center">
				<div class="wallet-status bg-success rounded-circle me-3"></div>
				<span>{{ shortenedWalletAddress }}</span>
			</div>
		</header>

		<!-- Display warning if on the wrong network -->
		<div v-if="onWrongNetwork" class="wrong-network-warning">
			<h2>Please Change Network</h2>
			<p>
				You are currently on the wrong network. Please switch to the Binance
				Smart Chain Testnet (Network ID: 97) to use this site.
			</p>
		</div>
		<div v-else>
			<!-- Wallet Connection -->
			<section v-if="!walletConnected">
				<div class="d-flex justify-content-center">
					<button class="btn btn-primary btn-lg" @click="connectWallet">
						Connect Wallet to Start
					</button>
				</div>
			</section>

			<!-- URL Shortener Section -->
			<div v-if="walletConnected" class="card p-4 shadow-lg mt-4">
				<div class="card-body d-flex">
					<input
						type="text"
						class="form-control"
						:class="{ 'is-invalid': isUrlTouched && !isValidUrl }"
						placeholder="Enter URL"
						v-model="url"
						@keyup.enter="submitUrl"
					/>
					<button
						class="btn btn-success ms-2"
						@click="submitUrl"
						:disabled="!isValidUrl"
					>
						Shorten
					</button>
				</div>
				<div v-if="!isValidUrl" class="text-danger mt-2">
					Please enter a valid URL.
				</div>
			</div>

			<!-- Shortened URL Result Section -->
			<section v-if="shortenedResult" class="result-card mt-4">
				<h4 class="mb-3">Shortened URL:</h4>
				<span class="fake-link" @click="copyToClipboard(shortenedResult)">
					{{ shortenedResult }}
				</span>
			</section>

			<!-- User URLs Table -->
			<section v-if="walletConnected && userUrls.length > 0" class="mt-5">
				<h2 class="mb-4">Your URLs</h2>
				<table class="table table-hover table-bordered">
					<thead>
						<tr>
							<th>Shortened URL</th>
							<th>Original URL</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="(item, index) in userUrls" :key="index">
							<td @click="copyToClipboard(getShortenedUrl(item.code))">
								<span class="fake-link">
									{{ getShortenedUrl(item.code) }}
								</span>
							</td>
							<td>{{ item.url }}</td>
						</tr>
					</tbody>
				</table>
			</section>
		</div>

		<!-- About TinyBlock Section -->
		<section class="about-tinyblock mt-5">
			<h2>About TinyBlock</h2>
			<p>
				Welcome to <strong>TinyBlock</strong>! Our service isn't just another
				URL shortener. We're revolutionizing the way URL shortening works by
				leveraging the power and trust of the blockchain.
			</p>

			<h3>Why Choose TinyBlock?</h3>
			<ol>
				<li>
					<strong>Decentralization</strong>: Unlike traditional services that
					rely on centralized servers and databases, TinyBlock operates on the
					Binance Smart Chain. This means no single entity has control over your
					shortened URLs. It's truly a service by the people, for the people.
				</li>
				<li>
					<strong>Immutability</strong>: Once a URL is shortened and stored on
					the blockchain, it's there forever. There's no risk of the service
					going down or your URLs getting lost because a company shuts down or
					faces technical issues.
				</li>
				<li>
					<strong>Transparency</strong>: Every transaction, including the
					creation of a shortened URL, is recorded on the blockchain. This means
					you can verify and trace every URL, ensuring total transparency and
					trustworthiness.
				</li>
				<li>
					<strong>Security</strong>: Centralized systems are prone to hacks,
					data breaches, and other vulnerabilities. By decentralizing and using
					the inherent security of blockchain, your data is much more secure.
				</li>
				<li>
					<strong>Censorship-Resistant</strong>: Traditional URL shorteners can
					be subjected to censorship or restrictions by governments or
					corporations. With TinyBlock, once a URL is on the blockchain, it
					can't be removed or altered by any central authority.
				</li>
				<li>
					<strong>Cost-Efficient</strong>: While some blockchain transactions
					may have fees, they often pale in comparison to the costs associated
					with maintaining centralized servers and infrastructure. Plus, with
					TinyBlock, there are no hidden fees or subscription costs.
				</li>
			</ol>

			<p>
				Embrace the future of URL shortening with TinyBlock, where
				decentralization meets utility, providing you with a reliable and
				trust-worthy service.
			</p>
		</section>

		<!-- Footer -->
		<footer class="footer">
			<div class="footer-content">
				<p>
					Contract Address:
					<a
						:href="bscScanLink"
						target="_blank"
						rel="noopener noreferrer"
						v-text="contractAddress"
					></a>
				</p>
				<p>Frontend code developed by ChatGPT</p>
				<p>
					Smart Contract by
					<a href="https://myapp.sh" target="_blank">Scott Deutsch</a>
				</p>
				<p>
					&copy; {{ currentYear }}
					<a href="https://myapp.sh" target="_blank">Scott Deutsch</a>
				</p>
			</div>
		</footer>

		<Toast ref="toast" />
	</div>
</template>

<script>
	import Toast from "./Toast.vue"
	import Web3 from "web3"
	import TinyBlock from "../../../build/contracts/TinyBlock.json"
	import Chain from "@/configs/Chain"

	export default {
		components: {
			Toast,
		},
		data() {
			return {
				url: "",
				isValidUrl: true,
				walletConnected: false,
				userUrls: [],
				walletAddress: "",
				isUrlTouched: false,
				shortenedResult: "",
				contract: null,
				contractAddress: "",
				onWrongNetwork: false,
			}
		},
		async created() {
			await this.initializeWeb3()
			await this.checkConnection()
			await this.checkNetwork()
			if (this.web3) {
				const keys = Object.keys(TinyBlock.networks)
				const lastKey = +keys[keys.length - 1]
				const nid = Chain.local ? lastKey : Chain.mainnet ? 56 : 97
				this.contractAddress =
					TinyBlock.networks[nid].address ??
					"0x1234567890abcdef1234567890abcdef12345678"
				this.contract = new this.web3.eth.Contract(
					TinyBlock.abi,
					this.contractAddress
				)
				this.loadUserUrls()
			}
		},
		computed: {
			currentYear() {
				return new Date().getFullYear()
			},
			bscScanLink() {
				return `https://testnet.bscscan.com/address/${this.contractAddress}`
			},
			shortenedWalletAddress() {
				if (this.walletAddress.length > 0) {
					return (
						this.walletAddress.slice(0, 6) +
						"..." +
						this.walletAddress.slice(-3)
					)
				}
				return ""
			},
		},
		methods: {
			async checkNetwork() {
				if (!this.web3) return

				try {
					const networkId = await this.web3.eth.getChainId()
					const nid = Chain.getChainId()
					// console.log(networkId, nid)
					if (networkId !== nid) {
						// alert(
						// 	"Please connect to the Binance Smart Chain Testnet (Network ID: 97) to use this site."
						// )
						// Or you can update a data property to show a more user-friendly modal/dialog with the message
						this.onWrongNetwork = true
					} else {
						this.onWrongNetwork = false
					}
				} catch (error) {
					console.error("Failed to get network ID:", error)
					// Handle error, maybe show an error message to the user
				}
			},
			async loadUserUrls() {
				if (!this.walletConnected || !this.contract || this.onWrongNetwork)
					return

				try {
					const userUrls = await this.contract.methods
						.getAllUserUrls(this.walletAddress)
						.call()

					// Update your data property with the fetched URLs
					// console.log(userUrls)
					this.userUrls = userUrls.map((data) => ({
						code: data.code,
						url: data.url,
					}))
				} catch (error) {
					console.error("Failed to load user URLs:", error)
					// Handle error, maybe show an error message to the user
				}
			},
			async checkConnection() {
				if (!this.web3) return
				const accounts = await this.web3.eth.getAccounts()
				if (accounts.length > 0) {
					this.walletAddress = accounts[0]
					this.walletConnected = true
				}
			},
			async initializeWeb3() {
				this.web3 = new Web3(Web3.givenProvider)
				if (!window.ethereum && !window.web3) {
					alert("You have to install MetaMask!")
					return
				}
				window.ethereum.on("chainChanged", (chainId) => {
					// Convert hex to decimal
					const networkId = parseInt(chainId, 16)
					const nid = Chain.getChainId()
					// console.log(networkId, nid)
					if (networkId !== nid) {
						// alert(
						// 	"Please switch to the Binance Smart Chain Testnet (Network ID: 97) to use this site."
						// )
						// Or update a data property to show a more user-friendly message or modal
						this.onWrongNetwork = true
						this.loadUserUrls()
					} else {
						this.onWrongNetwork = false
					}
				})

				window.ethereum.on("accountsChanged", async (accounts) => {
					if (accounts.length === 0) {
						// User has disconnected their wallet
						this.walletConnected = false
						this.walletAddress = ""
					} else {
						// User has switched accounts
						this.walletAddress = accounts[0]
						// Reload user URLs for the new account
						await this.loadUserUrls()
						// Also, re-check the network, though typically it doesn't change when switching accounts
						await this.checkNetwork()
					}
				})
			},
			copyToClipboard(text) {
				navigator.clipboard
					.writeText(text)
					.then(() => {
						this.$refs.toast.show("URL copied to clipboard!", "success")
					})
					.catch((err) => {
						console.error("Could not copy text: ", err)
					})
			},
			getShortenedUrl(code) {
				return `${window.location.protocol}//${window.location.host}/${code}`
			},
			validateUrl() {
				const urlRegex =
					/^(https?:\/\/)([\w\-]+(\.[\w\-]+)+)([\w\-.,@?^=%&:/~+#]*[\w\-@?^=%&/~+#])?$/
				this.isValidUrl = urlRegex.test(this.url)
			},
			addHttpsPrefix() {
				if (
					!this.url.startsWith("https://") &&
					!this.url.startsWith("http://")
				) {
					this.url = "https://" + this.url
				}
			},
			async connectWallet() {
				try {
					const accounts = await this.web3.currentProvider.request({
						method: "eth_requestAccounts",
					})
					this.walletAddress = accounts[0]
					this.walletConnected = true
					this.checkNetwork()
					this.loadUserUrls()
				} catch (error) {
					console.error("Failed to connect to the wallet:", error)
					alert(
						"Failed to connect to the wallet. Please make sure you have MetaMask installed and are on the correct network."
					)
				}
			},
			async submitUrl() {
				if (!this.walletConnected || !this.url) return

				this.addHttpsPrefix() // Add "https://" prefix if not present
				this.validateUrl() // Validate the URL when submitting
				if (this.isValidUrl) {
					try {
						const receipt = await this.contract.methods
							.add(this.url)
							.send({ from: this.walletAddress })

						if (receipt.events.Add) {
							const eventData = receipt.events.Add.returnValues
							// console.log("Results", eventData)
							// Here, eventData will contain the details emitted from the Add event
							// For instance: eventData._user will give you the user's address, eventData._code will give you the shortened code, etc.
							// Handle the event data as you wish, e.g., show the shortened URL to the user
							const item = {
								url: eventData._url,
								code: eventData._code,
							}
							this.userUrls.push(item)
							this.shortenedResult = this.getShortenedUrl(item.code)
							this.url = "" // Clear the URL input after successfully shortening it
							this.isUrlTouched = false // Reset the touched status
						}
						this.$refs.toast.show("URL shortened successfully!", "success")
					} catch (error) {
						// Handle error, maybe show an error message to the user
						console.error("Failed to add URL:", error)
						this.$refs.toast.show(error.message, "error")
					}
				} else {
					this.isUrlTouched = true // Mark the URL input as "touched" to show validation errors
				}
			},
		},
	}
</script>

<style scoped lang="less">
	@keyframes shake {
		0%,
		100% {
			transform: translateX(0);
		}
		10%,
		30%,
		50%,
		70%,
		90% {
			transform: translateX(-10px);
		}
		20%,
		40%,
		60%,
		80% {
			transform: translateX(10px);
		}
	}

	.is-invalid {
		animation: shake 0.82s cubic-bezier(0.36, 0.07, 0.19, 0.97) both;
		border-color: #e3342f;
	}

	.fake-link {
		color: #007bff;
		text-decoration: underline;
		cursor: pointer;
	}

	.btn-primary {
		background-color: #3498db;
		border: none;
		transition: background-color 0.3s ease;
		&:hover {
			background-color: #2980b9;
		}
		font-size: 1.2rem;
		padding: 10px 30px;
		display: block;
		margin: 0 auto;
	}

	.btn-success {
		background-color: #2ecc71;
		border: none;
		transition: background-color 0.3s ease;
		&:hover {
			background-color: #27ae60;
		}
		border-top-left-radius: 0;
		border-bottom-left-radius: 0;
	}

	.card {
		border-radius: 15px;
		background: rgba(255, 255, 255, 0.9);
	}

	.result-card {
		padding: 20px;
		border-radius: 10px;
		background: rgba(255, 255, 255, 0.8);
		box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	}

	.result-url {
		display: block;
		padding: 10px;
		border-radius: 5px;
		background: #f8f9fa;
		color: #3498db;
		transition: background 0.3s ease;
		&:hover {
			background: #e9ecef;
		}
	}

	input.form-control {
		border-radius: 15px;
		transition: border 0.2s ease;
		border-top-right-radius: 0;
		border-bottom-right-radius: 0;
		&:focus {
			border-color: #3498db;
			box-shadow: none;
		}
	}

	.wallet-status {
		width: 10px;
		height: 10px;
	}

	.footer {
		padding: 20px;
		text-align: center;
		background: rgba(255, 255, 255, 0.1);
		backdrop-filter: blur(10px);
		border-top: 1px solid rgba(255, 255, 255, 0.2);
	}

	.footer-content p {
		margin: 5px 0;
		font-size: 0.9em;
	}

	.wrong-network-warning {
		text-align: center;
		padding: 50px;
		background-color: rgba(255, 0, 0, 0.1); /* Light red background */
		border: 1px solid red;
		border-radius: 15px;
		margin-top: 20px;
	}
</style>
