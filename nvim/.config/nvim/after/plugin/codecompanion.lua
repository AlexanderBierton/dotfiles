--[[
require("codecompanion").setup({
  strategies = {
    agent = {
      adapter = {
        name = "gemini",
        model = "gemini-2.5-flash"
      },
    },
    chat = {
      adapter = {
        name = "gemini",
        model = "gemini-2.5-flash"
      },
    },
    inline = {
      adapter = {
        name = "gemini",
        model = "gemini-2.5-flash"
      },
    },
  },
  adapters = {
    gemini = function()
      return require("codecompanion.adapters").extend("gemini", {
        env = {
          api_key = "GEMINI_API_KEY",
        }
      })
    end
  }
})

-- Keymaps
local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- <leader>a for Action Palette (The main one)
map({ "n", "v" }, "<leader>a", "<cmd>CodeCompanionActions<cr>", opt)

-- <leader>i for immediate inline
map({ "n", "v" }, "<leader>i", "<cmd>CodeCompanion<cr>", opt)
--
-- <leader>cc to Toggle Chat
map({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", opt)

-- ga to add selection to chat (Visual mode only)
map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", opt)

-- In order to pass context to the chat use the # key and you can send through what you want
--
]]
