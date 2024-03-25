return {
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = true
		require("lsp-inlayhints").on_attach(client, bufnr)
	end,
	settings = {},
}
