local function set_tmux_title()
	-- Only run if we are actually inside a tmux session
	if os.getenv("TMUX") then
		local dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
		-- We use pcall (protected call) just in case the tmux command itself fails
		pcall(function()
			vim.fn.system({ "tmux", "rename-window", dir })
		end)
	end
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
	callback = set_tmux_title,
})

-- Optional: Reset the title safely when leaving
vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		if os.getenv("TMUX") then
			pcall(function()
				vim.fn.system({ "tmux", "rename-window", "zsh" })
			end)
		end
	end,
})
